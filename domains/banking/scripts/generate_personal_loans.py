"""Generate personal_loans: choose --layout small or --layout large.

Each key identifies one row. total is the selected layout's row count.
References are deterministic: generate related tables with the same layout.
"""
from common import DATES, run


def generate_row(key, total):
    """Build one typed row in the same column order as ddl/personal_loans.sql."""
    # Loan IDs cycle HOME, PERSONAL, AUTO; select only this subtype.
    offset = 2
    population = (total - offset) // 3 + 1
    loan = (key - 1) % population * 3 + offset
    common = dict(snapshot_id=key, loan_id=loan)
    common.update(purpose=('HOME_IMPROVEMENT', 'DEBT_CONSOLIDATION', 'OTHER')[loan % 5 % 3], unsecured=True)
    common['snapshot_date'] = DATES[(key - 1) // population]
    return common


if __name__ == '__main__':
    run('personal_loans', generate_row)
