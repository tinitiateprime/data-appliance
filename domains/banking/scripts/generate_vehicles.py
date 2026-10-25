"""Generate vehicles: choose --layout small or --layout large.

Each key identifies one row. total is the selected layout's row count.
References are deterministic: generate related tables with the same layout.
"""
from common import cash, run


def generate_row(key, total):
    """Build one typed row in the same column order as ddl/vehicles.sql."""
    return dict(vehicle_id=key, vehicle_reference=f'TRAINING-VEHICLE-{key:07d}', manufacturer='Synthetic Motors', model_year=2020 + key % 5, vehicle_value=cash(40000 + key % 100 * 100))


if __name__ == '__main__':
    run('vehicles', generate_row)
