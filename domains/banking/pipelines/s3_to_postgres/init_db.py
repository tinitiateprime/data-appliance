"""Create the existing banking DDL in an already-created PostgreSQL database."""
import argparse
import psycopg
from settings import BANKING


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--layout', choices=('small', 'large', 'both'), default='both')
    args = parser.parse_args()
    layouts = ('small', 'large') if args.layout == 'both' else (args.layout,)
    # psycopg reads standard PGHOST/PGPORT/PGDATABASE/PGUSER/PGPASSWORD variables.
    with psycopg.connect() as conn:
        for layout in layouts:
            conn.execute((BANKING/f'schema_{layout}.sql').read_text(encoding='utf-8'))
            print(f'Created banking_{layout} tables (existing tables are retained).')


if __name__ == '__main__':
    main()
