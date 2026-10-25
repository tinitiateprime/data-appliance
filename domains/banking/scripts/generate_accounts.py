"""Generate accounts: choose --layout small or --layout large.

Each key identifies one row. total is the selected layout's row count.
References are deterministic: generate related tables with the same layout.
"""
from common import date, run


def generate_row(key, total):
    """Build one typed row in the same column order as ddl/accounts.sql."""
    return dict(account_id=key, product_id=key, branch_id=key, opened_date=date(2023, 1, 1), currency='USD', status='OPEN')


if __name__ == '__main__':
    run('accounts', generate_row)
