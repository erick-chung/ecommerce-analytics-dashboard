-- Rolling 3-month average revenue to smooth out seasonality trends
WITH monthly_revenue AS (
    SELECT 
        DATE_TRUNC('month', invoice_date)::DATE AS month,
        SUM(quantity * price) AS revenue
    FROM transactions
    WHERE invoice NOT LIKE 'C%'
    GROUP BY DATE_TRUNC('month', invoice_date)
),
revenue_with_rolling_avg AS (
    SELECT 
        month,
        revenue,
        AVG(revenue) OVER (
            ORDER BY month 
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS rolling_3month_avg
    FROM monthly_revenue
)
SELECT 
    month,
    ROUND(revenue, 2) AS monthly_revenue,
    ROUND(rolling_3month_avg, 2) AS rolling_3month_avg,
    ROUND(revenue - rolling_3month_avg, 2) AS variance_from_avg,
    ROUND(
        (revenue - rolling_3month_avg) / NULLIF(rolling_3month_avg, 0) * 100,
    2) AS variance_pct
FROM revenue_with_rolling_avg
ORDER BY month;