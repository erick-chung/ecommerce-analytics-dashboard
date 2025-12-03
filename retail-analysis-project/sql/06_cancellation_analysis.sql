-- Analysis of order cancellations and their impact
WITH all_transactions AS (
    SELECT 
        DATE_TRUNC('month', invoice_date)::DATE AS month,
        CASE 
            WHEN invoice LIKE 'C%' THEN 'Cancellation'
            ELSE 'Regular'
        END AS transaction_type,
        quantity * price AS transaction_value
    FROM transactions
    WHERE customer_id IS NOT NULL
),
monthly_summary AS (
    SELECT 
        month,
        transaction_type,
        COUNT(*) AS transaction_count,
        SUM(transaction_value) AS total_value
    FROM all_transactions
    GROUP BY month, transaction_type
)
SELECT 
    month,
    SUM(CASE WHEN transaction_type = 'Regular' THEN transaction_count ELSE 0 END) AS regular_transactions,
    SUM(CASE WHEN transaction_type = 'Cancellation' THEN transaction_count ELSE 0 END) AS cancelled_transactions,
    ROUND(SUM(CASE WHEN transaction_type = 'Regular' THEN total_value ELSE 0 END), 2) AS regular_revenue,
    ROUND(ABS(SUM(CASE WHEN transaction_type = 'Cancellation' THEN total_value ELSE 0 END)), 2) AS cancelled_revenue,
    ROUND(
        (SUM(CASE WHEN transaction_type = 'Cancellation' THEN transaction_count ELSE 0 END)::NUMERIC / 
         NULLIF(SUM(transaction_count), 0)) * 100,
    2) AS cancellation_rate_pct,
    ROUND(
        ABS(SUM(CASE WHEN transaction_type = 'Cancellation' THEN total_value ELSE 0 END)) / 
        NULLIF(SUM(CASE WHEN transaction_type = 'Regular' THEN total_value ELSE 0 END), 0) * 100, 
    2) AS revenue_impact_pct
FROM monthly_summary
GROUP BY month
ORDER BY month;