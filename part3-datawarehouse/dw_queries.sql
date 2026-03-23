-- ============================================================
-- Part 3 — Data Warehouse Analytical Queries
-- Based on star schema: fact_sales + dim_date + dim_store + dim_product
-- ============================================================

-- Q1: Total sales revenue by product category for each month
SELECT
    dd.year,
    dd.month,
    dd.month_name,
    dp.category,
    SUM(fs.total_revenue)  AS total_revenue,
    SUM(fs.units_sold)     AS total_units_sold
FROM fact_sales fs
JOIN dim_date    dd ON fs.date_key    = dd.date_key
JOIN dim_product dp ON fs.product_key = dp.product_key
GROUP BY dd.year, dd.month, dd.month_name, dp.category
ORDER BY dd.year, dd.month, dp.category;

-- Q2: Top 2 performing stores by total revenue
SELECT
    ds.store_name,
    ds.store_city,
    ds.store_region,
    SUM(fs.total_revenue) AS total_revenue,
    SUM(fs.units_sold)    AS total_units_sold,
    COUNT(fs.sale_id)     AS total_transactions
FROM fact_sales fs
JOIN dim_store ds ON fs.store_key = ds.store_key
GROUP BY ds.store_key, ds.store_name, ds.store_city, ds.store_region
ORDER BY total_revenue DESC
LIMIT 2;

-- Q3: Month-over-month sales trend across all stores
SELECT
    dd.year,
    dd.month,
    dd.month_name,
    SUM(fs.total_revenue)                                          AS monthly_revenue,
    LAG(SUM(fs.total_revenue)) OVER (ORDER BY dd.year, dd.month)  AS prev_month_revenue,
    ROUND(
        (SUM(fs.total_revenue) - LAG(SUM(fs.total_revenue)) OVER (ORDER BY dd.year, dd.month))
        / NULLIF(LAG(SUM(fs.total_revenue)) OVER (ORDER BY dd.year, dd.month), 0) * 100,
        2
    )                                                              AS mom_growth_percent
FROM fact_sales fs
JOIN dim_date dd ON fs.date_key = dd.date_key
GROUP BY dd.year, dd.month, dd.month_name
ORDER BY dd.year, dd.month;
