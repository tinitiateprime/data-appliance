"""Shared file writing and CLI; row-generation logic lives in each table script."""
import argparse
import csv
from dataclasses import dataclass
from datetime import date, timedelta
from decimal import Decimal
import hashlib
import importlib
from itertools import islice
import json
from pathlib import Path
import shutil

import pyarrow as pa
import pyarrow.parquet as pq

FORMATS = ('csv', 'json', 'parquet')
LAYOUTS = {'large': (10, 100000), 'small': (1000, 10)}
SNAPSHOTS = ('checking_accounts', 'savings_accounts', 'home_loans', 'personal_loans', 'auto_loans')
DATES = tuple(date(2024, 1, 1) + timedelta(days=i) for i in range(731))
CITIES = (('Chicago', 'IL'), ('Austin', 'TX'), ('Sacramento', 'CA'), ('New York', 'NY'))
CENT = Decimal('0.01')
ARROW_TYPES = {'bigint': pa.int64(), 'int': pa.int32(), 'text': pa.string(),
               'date': pa.date32(), 'decimal': pa.decimal128(18, 2), 'boolean': pa.bool_()}

@dataclass(frozen=True)
class Column:
    name: str
    kind: str
    ref: str = ''

MODEL = {'title': 'Synthetic banking scale fixtures with dated subtype snapshots',
 'tables': {'customers': [('customer_id', 'bigint', ''),
                          ('customer_name', 'text', ''),
                          ('dob', 'date', ''),
                          ('phone_number', 'text', ''),
                          ('gender', 'text', ''),
                          ('email', 'text', '')],
            'customer_address': [('address_id', 'bigint', ''),
                                 ('customer_id', 'bigint', 'customers'),
                                 ('address_line', 'text', ''),
                                 ('city', 'text', ''),
                                 ('state_code', 'text', ''),
                                 ('postal_code', 'text', '')],
            'branches': [('branch_id', 'bigint', ''),
                         ('branch_name', 'text', ''),
                         ('city', 'text', ''),
                         ('state_code', 'text', '')],
            'account_products': [('product_id', 'bigint', ''),
                                 ('product_name', 'text', ''),
                                 ('account_type', 'text', ''),
                                 ('annual_rate', 'decimal', '')],
            'accounts': [('account_id', 'bigint', ''),
                         ('product_id', 'bigint', 'account_products'),
                         ('branch_id', 'bigint', 'branches'),
                         ('opened_date', 'date', ''),
                         ('currency', 'text', ''),
                         ('status', 'text', '')],
            'account_owners': [('ownership_id', 'bigint', ''),
                               ('account_id', 'bigint', 'accounts'),
                               ('customer_id', 'bigint', 'customers'),
                               ('owner_role', 'text', '')],
            'checking_accounts': [('snapshot_id', 'bigint', ''),
                                  ('account_id', 'bigint', 'accounts'),
                                  ('overdraft_limit', 'decimal', ''),
                                  ('debit_card_enabled', 'boolean', ''),
                                  ('snapshot_date', 'date', '')],
            'savings_accounts': [('snapshot_id', 'bigint', ''),
                                 ('account_id', 'bigint', 'accounts'),
                                 ('minimum_balance', 'decimal', ''),
                                 ('withdrawal_limit', 'int', ''),
                                 ('snapshot_date', 'date', '')],
            'properties': [('property_id', 'bigint', ''),
                           ('address_line', 'text', ''),
                           ('city', 'text', ''),
                           ('state_code', 'text', ''),
                           ('appraised_value', 'decimal', '')],
            'vehicles': [('vehicle_id', 'bigint', ''),
                         ('vehicle_reference', 'text', ''),
                         ('manufacturer', 'text', ''),
                         ('model_year', 'int', ''),
                         ('vehicle_value', 'decimal', '')],
            'loans': [('loan_id', 'bigint', ''),
                      ('customer_id', 'bigint', 'customers'),
                      ('branch_id', 'bigint', 'branches'),
                      ('loan_type', 'text', ''),
                      ('principal', 'decimal', ''),
                      ('annual_rate', 'decimal', ''),
                      ('term_months', 'int', ''),
                      ('origination_date', 'date', ''),
                      ('status', 'text', '')],
            'home_loans': [('snapshot_id', 'bigint', ''),
                           ('loan_id', 'bigint', 'loans'),
                           ('property_id', 'bigint', 'properties'),
                           ('down_payment', 'decimal', ''),
                           ('snapshot_date', 'date', '')],
            'personal_loans': [('snapshot_id', 'bigint', ''),
                               ('loan_id', 'bigint', 'loans'),
                               ('purpose', 'text', ''),
                               ('unsecured', 'boolean', ''),
                               ('snapshot_date', 'date', '')],
            'auto_loans': [('snapshot_id', 'bigint', ''),
                           ('loan_id', 'bigint', 'loans'),
                           ('vehicle_id', 'bigint', 'vehicles'),
                           ('down_payment', 'decimal', ''),
                           ('snapshot_date', 'date', '')],
            'loan_payments': [('payment_id', 'bigint', ''),
                              ('loan_id', 'bigint', 'loans'),
                              ('due_date', 'date', ''),
                              ('principal_amount', 'decimal', ''),
                              ('interest_amount', 'decimal', ''),
                              ('status', 'text', '')],
            'account_transactions': [('transaction_id', 'bigint', ''),
                                     ('account_id', 'bigint', 'accounts'),
                                     ('transaction_date', 'date', ''),
                                     ('transaction_type', 'text', ''),
                                     ('amount', 'decimal', ''),
                                     ('currency', 'text', ''),
                                     ('status', 'text', '')]},
 'unique': {'account_owners': [('account_id', 'customer_id')],
            'checking_accounts': [('account_id', 'snapshot_date')],
            'savings_accounts': [('account_id', 'snapshot_date')],
            'home_loans': [('loan_id', 'snapshot_date')],
            'personal_loans': [('loan_id', 'snapshot_date')],
            'auto_loans': [('loan_id', 'snapshot_date')]}}
MODEL['tables'] = {name: [Column(*c) for c in cols] for name, cols in MODEL['tables'].items()}

def cash(value):
    return Decimal(value).quantize(CENT)

def loan_values(key):
    kind = ('HOME', 'PERSONAL', 'AUTO')[(key - 1) % 3]
    principal, rate, months = {'HOME': (200000 + key % 1000 * 100, '0.06', 360), 'PERSONAL': (5000 + key % 100 * 100, '0.12', 36), 'AUTO': (20000 + key % 100 * 100, '0.08', 60)}[kind]
    return (kind, cash(principal), Decimal(rate), months)

def json_value(value):
    if isinstance(value, Decimal):
        return float(value)
    if isinstance(value, date):
        return value.isoformat()
    raise TypeError(type(value).__name__)

def write_file(path, rows, columns, fmt):
    path.parent.mkdir(parents=True, exist_ok=True)
    if fmt == 'csv':
        with path.open('w', encoding='utf-8', newline='') as f:
            writer = csv.DictWriter(f, fieldnames=[c.name for c in columns])
            writer.writeheader()
            writer.writerows(rows)
    elif fmt == 'json':
        with path.open('w', encoding='utf-8', newline='\n') as f:
            for row in rows:
                f.write(json.dumps(row, default=json_value) + '\n')
    else:
        schema = pa.schema([pa.field(c.name, ARROW_TYPES[c.kind], nullable=False) for c in columns])
        with pq.ParquetWriter(path, schema=schema, compression='snappy') as writer:
            iterator = iter(rows)
            while (chunk := list(islice(iterator, 10000))):
                writer.write_table(pa.Table.from_pylist(chunk, schema=schema))

def digest(path):
    with path.open('rb') as source:
        return hashlib.file_digest(source, 'sha256').hexdigest()

def schema_files(output):
    """Copy the matching schema documentation from this repository to the output."""
    source = Path(__file__).resolve().parent.parent
    for filename in ('schema_large.sql', 'schema_small.sql', 'erd.mmd', 'ERD.md'):
        shutil.copyfile(source/filename, output/filename)
    shutil.copytree(source/'ddl', output/'ddl', dirs_exist_ok=True)


def generate_table(name, row_factory, output, formats=FORMATS, layouts=('large', 'small')):
    if name not in MODEL['tables'] or not formats or (not set(formats) <= set(FORMATS)) or (not layouts) or (not set(layouts) <= set(LAYOUTS)):
        raise ValueError('Invalid table, format or layout')
    output = Path(output).resolve()
    manifest_path = output / 'manifest.json'
    if manifest_path.exists():
        manifest = json.loads(manifest_path.read_text(encoding='utf-8'))
        if manifest.get('generator') != 'banking-scale-v3':
            raise ValueError('Use a fresh folder for v3; existing dataset has a different schema/layout')
    else:
        if output.exists() and any(output.iterdir()):
            raise FileExistsError('Nonempty folder without a committed manifest; choose a fresh folder')
        manifest = {'version': 3, 'generator': 'banking-scale-v3', 'domain': 'banking', 'layouts': {k: {'files_per_table_per_format': v[0], 'rows_per_file': v[1], 'rows_per_table': v[0] * v[1]} for k, v in LAYOUTS.items()}, 'snapshot_tables': list(SNAPSHOTS), 'files': []}
    for layout in layouts:
        for fmt in formats:
            if (output / layout / name / fmt).exists():
                raise FileExistsError(f'Already exists: {layout}/{name}/{fmt}')
    output.mkdir(parents=True, exist_ok=True)
    created = []
    for layout in layouts:
        parts, size = LAYOUTS[layout]
        total = parts * size
        for part in range(parts):
            rows = [row_factory(key, total) for key in range(part * size + 1, (part + 1) * size + 1)]
            for fmt in formats:
                relative = Path(layout) / name / fmt / f'part-{part:05d}.{fmt}'
                path = output / relative
                write_file(path, rows, MODEL['tables'][name], fmt)
                created.append({'path': relative.as_posix(), 'table': name, 'layout': layout, 'format': fmt, 'rows': size, 'bytes': path.stat().st_size, 'sha256': digest(path)})
            if layout == 'large':
                print(f'{name}: large {part + 1}/{parts}', flush=True)
        print(f'{name}: {layout} complete ({parts} x {size} per format)', flush=True)
    manifest['files'].extend(created)
    actual = {(e['layout'], e['table'], e['format']) for e in manifest['files']}
    expected = {(l, t, f) for l in LAYOUTS for t in MODEL['tables'] for f in FORMATS}
    manifest['dataset_complete'] = actual == expected
    schema_files(output)
    temporary = manifest_path.with_suffix('.json.tmp')
    temporary.write_text(json.dumps(manifest, indent=2) + '\n', encoding='utf-8')
    temporary.replace(manifest_path)
    return created

def run(table_name=None, row_factory=None, fixed_layout=None):
    parser = argparse.ArgumentParser(description='Generate deterministic synthetic banking files.')
    parser.add_argument('--output', type=Path, required=True,
                        help='Dataset root; small/ and large/ are created below it.')
    parser.add_argument('--format', choices=['all', *FORMATS], default='all')
    if fixed_layout is None:
        parser.add_argument('--layout', choices=tuple(LAYOUTS), required=True)
    args = parser.parse_args()
    layout = fixed_layout or args.layout
    formats = FORMATS if args.format == 'all' else (args.format,)
    names = tuple(MODEL['tables']) if table_name is None else (table_name,)
    # Check every requested destination before writing any table.
    for name in names:
        for fmt in formats:
            if (args.output/layout/name/fmt).exists():
                parser.error(f'Already exists: {args.output/layout/name/fmt}. Choose a fresh output root.')
    for name in names:
        factory = row_factory if table_name else importlib.import_module('generate_'+name).generate_row
        generate_table(name, factory, args.output, formats, (layout,))
    print(f'Finished {len(names)} table(s): {args.output.resolve()/layout}', flush=True)
