-- Total revenue and customer count by country
WITH customer_totals AS (
    SELECT 
        customer_id,
        country,
        SUM(quantity * price) AS total_revenue,
        COUNT(DISTINCT invoice) AS total_orders
    FROM transactions
    WHERE invoice NOT LIKE 'C%'
        AND customer_id IS NOT NULL
    GROUP BY customer_id, country
)
SELECT 
    country,
    COUNT(DISTINCT customer_id) AS customer_count,
    ROUND(SUM(total_revenue), 2) AS total_revenue,
    ROUND(AVG(total_revenue), 2) AS avg_revenue_per_customer,
    SUM(total_orders) AS total_orders
FROM customer_totals
GROUP BY country
ORDER BY total_revenue DESC;