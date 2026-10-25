"""Read PostgreSQL and check selected table counts after loading."""
import argparse
import psycopg
from psycopg import sql
from settings import LAYOUTS, selected_tables


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--layout', choices=LAYOUTS, required=True)
    parser.add_argument('--tables', default='all')
    args = parser.parse_args()
    expected = LAYOUTS[args.layout][0] * LAYOUTS[args.layout][1]
    failed = False
    with psycopg.connect() as conn:
        for table in selected_tables(args.tables):
            count = conn.execute(sql.SQL('SELECT count(*) FROM {}').format(sql.Identifier(f'banking_{args.layout}', table))).fetchone()[0]
            print(f'{table}: {count:,} rows; expected {expected:,}')
            failed |= count != expected
    if failed:
        raise SystemExit('Row count verification failed')


if __name__ == '__main__':
    main()
