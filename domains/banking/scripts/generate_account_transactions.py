"""Generate account_transactions: choose --layout small or --layout large.

Each key identifies one row. total is the selected layout's row count.
References are deterministic: generate related tables with the same layout.
"""
from common import DATES, CENT, Decimal, run


def generate_row(key, total):
    """Build one typed row in the same column order as ddl/account_transactions.sql."""
    active = total // 4
    withdrawal = (key - 1) // active % 2 == 1
    value = (Decimal(100 + key * 37 % 200000) / 100).quantize(CENT)
    return dict(transaction_id=key, account_id=(key - 1) % active + 1, transaction_date=DATES[(key - 1) % 731], transaction_type='WITHDRAWAL' if withdrawal else 'DEPOSIT', amount=-value if withdrawal else value, currency='USD', status='POSTED')


if __name__ == '__main__':
    run('account_transactions', generate_row)
