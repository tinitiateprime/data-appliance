"""Upload and verify the full GitHub banking dataset in Floci S3."""
import argparse
from collections import Counter
from concurrent.futures import ThreadPoolExecutor
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import subprocess

import boto3
from botocore.config import Config
from botocore.exceptions import ClientError
from settings import BANKING, LAYOUTS, MODEL, required


def list_objects(client, bucket, prefix):
    result = {}
    for page in client.get_paginator('list_objects_v2').paginate(Bucket=bucket, Prefix=prefix):
        for obj in page.get('Contents', []):
            result[obj['Key']] = (obj['Size'], obj['ETag'].strip('"'))
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--workers', type=int, default=12)
    parser.add_argument('--report', type=Path, help='Optional local JSON receipt path')
    args = parser.parse_args()
    if not 1 <= args.workers <= 32:
        parser.error('--workers must be between 1 and 32')
    manifest_bytes = (BANKING/'manifest.json').read_bytes()
    manifest = json.loads(manifest_bytes)
    entries = manifest['files']
    counts = Counter((e['layout'], e['table'], e['format']) for e in entries)
    expected = {(layout, table, fmt): size[0] for layout, size in LAYOUTS.items()
                for table in MODEL['tables'] for fmt in ('csv', 'json', 'parquet')}
    if counts != expected or len({e['path'] for e in entries}) != len(entries):
        raise ValueError('The manifest must describe the complete, unique banking v3 dataset')
    commit = subprocess.check_output(['git', '-C', str(BANKING), 'rev-parse', 'HEAD'], text=True).strip()
    # Verify local contents before any S3 writes. Preserve the exact GitHub bytes.
    hashes = {}
    for entry in entries:
        relative = Path(entry['path'])
        path = (BANKING/relative).resolve()
        if not path.is_relative_to(BANKING.resolve()):
            raise ValueError('Manifest path escapes the banking folder')
        data = path.read_bytes()
        if len(data) != entry['bytes'] or hashlib.sha256(data).hexdigest() != entry['sha256']:
            raise ValueError(f"Local file differs from GitHub manifest: {entry['path']}")
        hashes[entry['path']] = hashlib.md5(data, usedforsecurity=False).hexdigest()
    print(f'Verified {len(entries):,} local files against manifest; checkout {commit}', flush=True)
    region = os.environ.get('AWS_DEFAULT_REGION', 'us-east-1')
    client = boto3.client('s3', endpoint_url=required('S3_ENDPOINT'), region_name=region,
                          config=Config(s3={'addressing_style': 'path'}, max_pool_connections=args.workers,
                                        retries={'mode': 'standard', 'max_attempts': 5}))
    bucket = required('S3_BUCKET')
    prefix = os.environ.get('S3_PREFIX', 'banking/v3').strip('/')
    root = prefix+'/' if prefix else ''
    try:
        client.head_bucket(Bucket=bucket)
    except ClientError as exc:
        if str(exc.response['Error']['Code']) not in ('404', 'NoSuchBucket', 'NotFound'):
            raise
        options = {} if region == 'us-east-1' else {'CreateBucketConfiguration': {'LocationConstraint': region}}
        client.create_bucket(Bucket=bucket, **options)
    existing = list_objects(client, bucket, root)

    def upload(entry):
        key = root+entry['path']
        expected_object = (entry['bytes'], hashes[entry['path']])
        if existing.get(key) == expected_object:
            return 'skipped'
        # One PUT per file: Floci's unencrypted, single-part ETag is the content MD5.
        with (BANKING/entry['path']).open('rb') as body:
            response = client.put_object(Bucket=bucket, Key=key, Body=body,
                                         Metadata={'sha256': entry['sha256'], 'rows': str(entry['rows'])})
        if response['ETag'].strip('"') != hashes[entry['path']]:
            raise ValueError(f'Uploaded content checksum mismatch: {key}')
        return 'uploaded'

    results = Counter()
    with ThreadPoolExecutor(max_workers=args.workers) as pool:
        for number, result in enumerate(pool.map(upload, entries), 1):
            results[result] += 1
            if number % 1000 == 0 or number == len(entries):
                print(f'{number:,}/{len(entries):,}: {results["uploaded"]:,} uploaded, {results["skipped"]:,} unchanged', flush=True)
    actual = list_objects(client, bucket, root)
    for entry in entries:
        if actual.get(root+entry['path']) != (entry['bytes'], hashes[entry['path']]):
            raise ValueError(f"S3 verification failed: {entry['path']}")
    expected_keys = {root+entry['path'] for entry in entries}
    extra = [key for key in actual if key.startswith((root+'small/', root+'large/')) and key not in expected_keys]
    if extra:
        raise ValueError(f'Found {len(extra)} extra objects under dataset layouts; inspect or choose a new prefix')
    report = {'verified_at_utc': datetime.now(timezone.utc).isoformat(),
              'source_repository': 'https://github.com/tinitiateprime/data-appliance',
              'source_commit': commit, 'manifest_sha256': hashlib.sha256(manifest_bytes).hexdigest(),
              'bucket': bucket, 'prefix': prefix, 'data_files': len(entries),
              'data_bytes': sum(e['bytes'] for e in entries),
              'uploaded': results['uploaded'], 'skipped_unchanged': results['skipped'],
              'verification': 'All object sizes and single-part MD5 ETags match verified local manifest files',
              'counts': [{'layout': l, 'table': t, 'format': f, 'files': n}
                         for (l, t, f), n in sorted(counts.items())]}
    receipt = (json.dumps(report, indent=2)+'\n').encode()
    client.put_object(Bucket=bucket, Key=root+'_metadata/manifest.json', Body=manifest_bytes)
    client.put_object(Bucket=bucket, Key=root+'_metadata/upload_receipt.json', Body=receipt)
    if args.report:
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_bytes(receipt)
    print(f'VERIFIED: {len(entries):,} data files at s3://{bucket}/{root}', flush=True)


if __name__ == '__main__':
    main()
