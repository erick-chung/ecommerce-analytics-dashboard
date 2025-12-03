-- Monthly revenue with year-over-year growth analysis
WITH monthly_revenue AS (
    SELECT 
        DATE_TRUNC('month', invoice_date)::DATE AS month,
        SUM(quantity * price) AS revenue
    FROM transactions
    WHERE invoice NOT LIKE 'C%'
    GROUP BY DATE_TRUNC('month', invoice_date)
),
revenue_with_comparisons AS (
    SELECT 
        month,
        revenue,
        LAG(revenue, 12) OVER (ORDER BY month) AS revenue_year_ago
    FROM monthly_revenue
)
SELECT 
    month,
    ROUND(revenue, 2) AS revenue,
    ROUND(revenue_year_ago, 2) AS revenue_year_ago,
    ROUND(
        CASE 
            WHEN revenue_year_ago IS NULL THEN NULL
            ELSE ((revenue - revenue_year_ago) / revenue_year_ago * 100)
        END, 
    2) AS yoy_growth_pct
FROM revenue_with_comparisons
ORDER BY month;