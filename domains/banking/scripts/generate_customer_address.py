"""Generate customer_address: choose --layout small or --layout large.

Each key identifies one row. total is the selected layout's row count.
References are deterministic: generate related tables with the same layout.
"""
from common import CITIES, run


def generate_row(key, total):
    """Build one typed row in the same column order as ddl/customer_address.sql."""
    city, state = CITIES[(key - 1) % 4]
    return dict(address_id=key, customer_id=key, address_line=f'{key} Fictional Training Lane', city=city, state_code=state, postal_code=f'{10000 + key % 90000:05d}')


if __name__ == '__main__':
    run('customer_address', generate_row)
