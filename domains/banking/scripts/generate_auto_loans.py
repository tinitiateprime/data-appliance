"""Generate auto_loans: choose --layout small or --layout large.

Each key identifies one row. total is the selected layout's row count.
References are deterministic: generate related tables with the same layout.
"""
from common import DATES, cash, run


def generate_row(key, total):
    """Build one typed row in the same column order as ddl/auto_loans.sql."""
    # Loan IDs cycle HOME, PERSONAL, AUTO; select only this subtype.
    offset = 3
    population = (total - offset) // 3 + 1
    loan = (key - 1) % population * 3 + offset
    common = dict(snapshot_id=key, loan_id=loan)
    common.update(vehicle_id=loan, down_payment=cash(5000))
    common['snapshot_date'] = DATES[(key - 1) // population]
    return common


if __name__ == '__main__':
    run('auto_loans', generate_row)
