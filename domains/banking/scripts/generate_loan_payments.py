"""Generate loan_payments: choose --layout small or --layout large.

Each key identifies one row. total is the selected layout's row count.
References are deterministic: generate related tables with the same layout.
"""
from common import CENT, date, loan_values, run


def generate_row(key, total):
    """Build one typed row in the same column order as ddl/loan_payments.sql."""
    _, principal, rate, months = loan_values(key)
    return dict(payment_id=key, loan_id=key, due_date=date(2024, 2, 1), principal_amount=(principal / months).quantize(CENT), interest_amount=(principal * rate / 12).quantize(CENT), status='SCHEDULED')


if __name__ == '__main__':
    run('loan_payments', generate_row)
