-- Customer cohort retention analysis
WITH first_purchase AS (
    SELECT 
        customer_id,
        DATE_TRUNC('month', MIN(invoice_date))::DATE AS cohort_month
    FROM transactions
    WHERE invoice NOT LIKE 'C%'
        AND customer_id IS NOT NULL
    GROUP BY customer_id
),
customer_activity AS (
    SELECT 
        t.customer_id,
        fp.cohort_month,
        DATE_TRUNC('month', t.invoice_date)::DATE AS activity_month
    FROM transactions t
    JOIN first_purchase fp ON t.customer_id = fp.customer_id
    WHERE t.invoice NOT LIKE 'C%'
    GROUP BY t.customer_id, fp.cohort_month, DATE_TRUNC('month', t.invoice_date)
),
cohort_size AS (
    SELECT 
        cohort_month,
        COUNT(DISTINCT customer_id) AS cohort_customers
    FROM first_purchase
    GROUP BY cohort_month
),
retention_data AS (
    SELECT 
        ca.cohort_month,
        ca.activity_month,
        COUNT(DISTINCT ca.customer_id) AS active_customers,
        cs.cohort_customers,
        (EXTRACT(YEAR FROM AGE(ca.activity_month, ca.cohort_month)) * 12 + 
         EXTRACT(MONTH FROM AGE(ca.activity_month, ca.cohort_month)))::INTEGER AS months_since_first
    FROM customer_activity ca
    JOIN cohort_size cs ON ca.cohort_month = cs.cohort_month
    GROUP BY ca.cohort_month, ca.activity_month, cs.cohort_customers
)
SELECT 
    cohort_month,
    months_since_first,
    cohort_customers,
    active_customers,
    ROUND((active_customers::NUMERIC / cohort_customers * 100), 2) AS retention_pct
FROM retention_data
WHERE cohort_month >= '2011-01-01'  -- Focus on 2011 cohorts
ORDER BY cohort_month, months_since_first;