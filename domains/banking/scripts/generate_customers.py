"""Generate customers: choose --layout small or --layout large.

Each key identifies one row. total is the selected layout's row count.
References are deterministic: generate related tables with the same layout.
"""
from common import date, run


def generate_row(key, total):
    """Build one typed row in the same column order as ddl/customers.sql."""
    return dict(customer_id=key, customer_name=f'Synthetic Customer {key:07d}', dob=date(1950 + key % 50, 1 + key % 12, 1 + key % 28), phone_number=f'TEST-PHONE-{key:07d}', gender=('Female', 'Male', 'Nonbinary', 'Unspecified')[key % 4], email=f'customer{key}@example.invalid')


if __name__ == '__main__':
    run('customers', generate_row)
