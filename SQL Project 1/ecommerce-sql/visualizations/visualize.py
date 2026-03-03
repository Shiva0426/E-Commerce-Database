"""
E-Commerce Data Visualization
Connects to MySQL and generates charts using Matplotlib
"""

import mysql.connector
import matplotlib
matplotlib.use('Agg')  # Non-interactive backend for saving files
import matplotlib.pyplot as plt
import os
import getpass

# ---- Database Connection ----
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': getpass.getpass('Enter MySQL root password: '),
    'database': 'ecommerce_db'
}

# Output directory for charts
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
OUTPUT_DIR = SCRIPT_DIR
os.makedirs(OUTPUT_DIR, exist_ok=True)

# ---- Style Configuration ----
COLORS = ['#6366f1', '#f43f5e', '#10b981', '#f59e0b', '#3b82f6', '#8b5cf6', '#ec4899', '#14b8a6']
plt.rcParams.update({
    'figure.facecolor': '#1e1e2e',
    'axes.facecolor': '#1e1e2e',
    'text.color': '#cdd6f4',
    'axes.labelcolor': '#cdd6f4',
    'xtick.color': '#a6adc8',
    'ytick.color': '#a6adc8',
    'axes.edgecolor': '#45475a',
    'font.family': 'sans-serif',
    'font.size': 11,
})


def get_connection():
    return mysql.connector.connect(**DB_CONFIG)


def chart_revenue_by_category(cursor):
    """Bar chart: Revenue by product category"""
    cursor.execute("""
        SELECT c.name AS category, SUM(oi.subtotal) AS revenue
        FROM order_items oi
        JOIN products p ON p.product_id = oi.product_id
        JOIN categories c ON c.category_id = p.category_id
        JOIN orders o ON o.order_id = oi.order_id
        WHERE o.status NOT IN ('cancelled', 'returned')
        GROUP BY c.category_id, c.name
        ORDER BY revenue DESC
    """)
    rows = cursor.fetchall()
    if not rows:
        print("No data for revenue by category.")
        return

    categories = [r[0] for r in rows]
    revenue = [float(r[1]) for r in rows]

    fig, ax = plt.subplots(figsize=(10, 6))
    bars = ax.bar(categories, revenue, color=COLORS[:len(categories)], edgecolor='none', width=0.6)
    ax.set_title('Revenue by Category', fontsize=16, fontweight='bold', pad=15)
    ax.set_ylabel('Revenue (₹)', fontsize=12)
    for bar, val in zip(bars, revenue):
        ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + max(revenue)*0.02,
                f'₹{val:,.0f}', ha='center', va='bottom', fontsize=10, color='#cdd6f4')
    ax.set_ylim(0, max(revenue) * 1.2)
    ax.grid(axis='y', alpha=0.15)
    plt.tight_layout()
    path = os.path.join(OUTPUT_DIR, 'chart_revenue_by_category.png')
    plt.savefig(path, dpi=150)
    plt.close()
    print(f"  ✅ Saved: {path}")


def chart_order_status(cursor):
    """Pie chart: Order status distribution"""
    cursor.execute("""
        SELECT status, COUNT(*) AS cnt
        FROM orders
        GROUP BY status
        ORDER BY cnt DESC
    """)
    rows = cursor.fetchall()
    if not rows:
        print("No data for order status.")
        return

    labels = [r[0].capitalize() for r in rows]
    sizes = [r[1] for r in rows]

    fig, ax = plt.subplots(figsize=(8, 8))
    wedges, texts, autotexts = ax.pie(
        sizes, labels=labels, autopct='%1.1f%%',
        colors=COLORS[:len(labels)],
        startangle=140,
        textprops={'color': '#cdd6f4', 'fontsize': 12},
        wedgeprops={'edgecolor': '#1e1e2e', 'linewidth': 2}
    )
    for autotext in autotexts:
        autotext.set_fontweight('bold')
    ax.set_title('Order Status Distribution', fontsize=16, fontweight='bold', pad=20)
    plt.tight_layout()
    path = os.path.join(OUTPUT_DIR, 'chart_order_status.png')
    plt.savefig(path, dpi=150)
    plt.close()
    print(f"  ✅ Saved: {path}")


def chart_payment_methods(cursor):
    """Bar chart: Payment method breakdown"""
    cursor.execute("""
        SELECT method, COUNT(*) AS transactions, SUM(amount) AS total
        FROM payments
        WHERE status = 'completed'
        GROUP BY method
        ORDER BY total DESC
    """)
    rows = cursor.fetchall()
    if not rows:
        print("No data for payment methods.")
        return

    methods = [r[0].upper().replace('_', ' ') for r in rows]
    totals = [float(r[2]) for r in rows]
    counts = [r[1] for r in rows]

    fig, ax = plt.subplots(figsize=(10, 6))
    bars = ax.bar(methods, totals, color=COLORS[:len(methods)], edgecolor='none', width=0.5)
    ax.set_title('Payment Method Breakdown', fontsize=16, fontweight='bold', pad=15)
    ax.set_ylabel('Total Amount (₹)', fontsize=12)
    for bar, val, cnt in zip(bars, totals, counts):
        ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + max(totals)*0.02,
                f'₹{val:,.0f}\n({cnt} txns)', ha='center', va='bottom', fontsize=10, color='#cdd6f4')
    ax.set_ylim(0, max(totals) * 1.3)
    ax.grid(axis='y', alpha=0.15)
    plt.tight_layout()
    path = os.path.join(OUTPUT_DIR, 'chart_payment_methods.png')
    plt.savefig(path, dpi=150)
    plt.close()
    print(f"  ✅ Saved: {path}")


def chart_monthly_revenue(cursor):
    """Line chart: Monthly revenue trend"""
    cursor.execute("""
        SELECT DATE_FORMAT(ordered_at, '%Y-%m') AS month, SUM(total_amount) AS revenue
        FROM orders
        WHERE status NOT IN ('cancelled', 'returned')
        GROUP BY DATE_FORMAT(ordered_at, '%Y-%m')
        ORDER BY month
    """)
    rows = cursor.fetchall()
    if not rows:
        print("No data for monthly revenue.")
        return

    months = [r[0] for r in rows]
    revenue = [float(r[1]) for r in rows]

    fig, ax = plt.subplots(figsize=(10, 6))
    ax.plot(months, revenue, color='#6366f1', marker='o', linewidth=2.5, markersize=8,
            markerfacecolor='#f43f5e', markeredgecolor='#1e1e2e', markeredgewidth=2)
    ax.fill_between(months, revenue, alpha=0.15, color='#6366f1')
    ax.set_title('Monthly Revenue Trend', fontsize=16, fontweight='bold', pad=15)
    ax.set_ylabel('Revenue (₹)', fontsize=12)
    ax.set_xlabel('Month', fontsize=12)
    for i, (m, v) in enumerate(zip(months, revenue)):
        ax.annotate(f'₹{v:,.0f}', (m, v), textcoords="offset points",
                    xytext=(0, 12), ha='center', fontsize=9, color='#cdd6f4')
    ax.grid(axis='y', alpha=0.15)
    plt.xticks(rotation=45)
    plt.tight_layout()
    path = os.path.join(OUTPUT_DIR, 'chart_monthly_revenue.png')
    plt.savefig(path, dpi=150)
    plt.close()
    print(f"  ✅ Saved: {path}")


def chart_top_products(cursor):
    """Horizontal bar chart: Top 5 products by revenue"""
    cursor.execute("""
        SELECT p.name, SUM(oi.subtotal) AS revenue
        FROM order_items oi
        JOIN products p ON p.product_id = oi.product_id
        JOIN orders o ON o.order_id = oi.order_id
        WHERE o.status NOT IN ('cancelled', 'returned')
        GROUP BY p.product_id, p.name
        ORDER BY revenue DESC
        LIMIT 5
    """)
    rows = cursor.fetchall()
    if not rows:
        print("No data for top products.")
        return

    products = [r[0] for r in rows][::-1]
    revenue = [float(r[1]) for r in rows][::-1]

    fig, ax = plt.subplots(figsize=(10, 6))
    bars = ax.barh(products, revenue, color=COLORS[:len(products)], edgecolor='none', height=0.5)
    ax.set_title('Top 5 Products by Revenue', fontsize=16, fontweight='bold', pad=15)
    ax.set_xlabel('Revenue (₹)', fontsize=12)
    for bar, val in zip(bars, revenue):
        ax.text(val + max(revenue)*0.02, bar.get_y() + bar.get_height()/2,
                f'₹{val:,.0f}', ha='left', va='center', fontsize=10, color='#cdd6f4')
    ax.set_xlim(0, max(revenue) * 1.25)
    ax.grid(axis='x', alpha=0.15)
    plt.tight_layout()
    path = os.path.join(OUTPUT_DIR, 'chart_top_products.png')
    plt.savefig(path, dpi=150)
    plt.close()
    print(f"  ✅ Saved: {path}")


def main():
    print("\n📊 E-Commerce Data Visualization")
    print("=" * 40)

    try:
        conn = get_connection()
        cursor = conn.cursor()
        print("✅ Connected to MySQL database\n")

        print("Generating charts...")
        chart_revenue_by_category(cursor)
        chart_order_status(cursor)
        chart_payment_methods(cursor)
        chart_monthly_revenue(cursor)
        chart_top_products(cursor)

        print(f"\n🎉 All charts saved to: {OUTPUT_DIR}")

        cursor.close()
        conn.close()

    except mysql.connector.Error as e:
        print(f"\n❌ MySQL Error: {e}")
        print("Make sure to update DB_CONFIG with your MySQL password.")
    except Exception as e:
        print(f"\n❌ Error: {e}")


if __name__ == '__main__':
    main()
