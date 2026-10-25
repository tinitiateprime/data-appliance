"""Generate home_loans: choose --layout small or --layout large.

Each key identifies one row. total is the selected layout's row count.
References are deterministic: generate related tables with the same layout.
"""
from common import DATES, cash, run


def generate_row(key, total):
    """Build one typed row in the same column order as ddl/home_loans.sql."""
    # Loan IDs cycle HOME, PERSONAL, AUTO; select only this subtype.
    offset = 1
    population = (total - offset) // 3 + 1
    loan = (key - 1) % population * 3 + offset
    common = dict(snapshot_id=key, loan_id=loan)
    common.update(property_id=loan, down_payment=cash(50000))
    common['snapshot_date'] = DATES[(key - 1) // population]
    return common


if __name__ == '__main__':
    run('home_loans', generate_row)
