"""Generate account_products: choose --layout small or --layout large.

Each key identifies one row. total is the selected layout's row count.
References are deterministic: generate related tables with the same layout.
"""
from common import cash, run


def generate_row(key, total):
    """Build one typed row in the same column order as ddl/account_products.sql."""
    kind = 'CHECKING' if key % 2 else 'SAVINGS'
    return dict(product_id=key, product_name=f'Synthetic {kind.title()} Product {key:07d}', account_type=kind, annual_rate=cash('0.00' if key % 2 else '0.02'))


if __name__ == '__main__':
    run('account_products', generate_row)
