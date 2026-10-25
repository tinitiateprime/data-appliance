"""Generate properties: choose --layout small or --layout large.

Each key identifies one row. total is the selected layout's row count.
References are deterministic: generate related tables with the same layout.
"""
from common import CITIES, cash, run


def generate_row(key, total):
    """Build one typed row in the same column order as ddl/properties.sql."""
    city, state = CITIES[(key - 1) % 4]
    return dict(property_id=key, address_line=f'{key} Example Property Road', city=city, state_code=state, appraised_value=cash(400000 + key % 1000 * 100))


if __name__ == '__main__':
    run('properties', generate_row)
