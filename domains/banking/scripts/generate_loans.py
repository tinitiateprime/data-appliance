"""Generate loans: choose --layout small or --layout large.

Each key identifies one row. total is the selected layout's row count.
References are deterministic: generate related tables with the same layout.
"""
from common import date, loan_values, run


def generate_row(key, total):
    """Build one typed row in the same column order as ddl/loans.sql."""
    kind, principal, rate, months = loan_values(key)
    return dict(loan_id=key, customer_id=(key - 1) // 3 + 1, branch_id=key, loan_type=kind, principal=principal, annual_rate=rate, term_months=months, origination_date=date(2024, 1, 1), status='ACTIVE')


if __name__ == '__main__':
    run('loans', generate_row)
