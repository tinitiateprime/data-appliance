"""Generate account_owners: choose --layout small or --layout large.

Each key identifies one row. total is the selected layout's row count.
References are deterministic: generate related tables with the same layout.
"""
from common import run


def generate_row(key, total):
    """Build one typed row in the same column order as ddl/account_owners.sql."""
    # Four consecutive accounts share one customer: two checking and two savings.
    return dict(ownership_id=key, account_id=key, customer_id=(key - 1) // 4 + 1, owner_role='PRIMARY')


if __name__ == '__main__':
    run('account_owners', generate_row)
