"""Configuration and the existing banking model; never print connection secrets."""
import os
from pathlib import Path
import sys

BANKING = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(BANKING/'scripts'))
from common import MODEL, LAYOUTS


def required(name):
    value = os.environ.get(name)
    if not value:
        raise ValueError(f'Set {name} in your environment or .env file.')
    return value


def selected_tables(value):
    names = list(MODEL['tables']) if value == 'all' else value.split(',')
    if not names or any(name not in MODEL['tables'] for name in names):
        raise ValueError('Unknown table. Choose all or comma-separated banking table names.')
    # Model order is parent-first, even if the caller lists children first.
    return [name for name in MODEL['tables'] if name in names]


def s3_key(layout, table, fmt):
    prefix = os.environ.get('S3_PREFIX', 'banking/v3').strip('/')
    return '/'.join(filter(None, (prefix, layout, table, fmt)))
