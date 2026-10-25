"""Generate branches: choose --layout small or --layout large.

Each key identifies one row. total is the selected layout's row count.
References are deterministic: generate related tables with the same layout.
"""
from common import CITIES, run


def generate_row(key, total):
    """Build one typed row in the same column order as ddl/branches.sql."""
    city, state = CITIES[(key - 1) % 4]
    return dict(branch_id=key, branch_name=f'Training Branch {key:07d}', city=city, state_code=state)


if __name__ == '__main__':
    run('branches', generate_row)
