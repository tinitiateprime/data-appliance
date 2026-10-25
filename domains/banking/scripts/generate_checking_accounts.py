"""Generate checking_accounts: choose --layout small or --layout large.

Each key identifies one row. total is the selected layout's row count.
References are deterministic: generate related tables with the same layout.
"""
from common import DATES, cash, run


def generate_row(key, total):
    """Build one typed row in the same column order as ddl/checking_accounts.sql."""
    # Odd IDs are checking, even IDs are savings. Repeat parents on a new date.
    sequence = (key - 1) % (total // 2)
    account = sequence * 2 + 1
    common = dict(snapshot_id=key, account_id=account)
    common.update(overdraft_limit=cash(500), debit_card_enabled=True)
    common['snapshot_date'] = DATES[(key - 1) // (total // 2)]
    return common


if __name__ == '__main__':
    run('checking_accounts', generate_row)
