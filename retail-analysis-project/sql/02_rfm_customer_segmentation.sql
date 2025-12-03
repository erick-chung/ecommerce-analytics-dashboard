-- RFM (Recency, Frequency, Monetary) customer segmentation analysis
-- Recency calculated relative to dataset end date (not current date)
WITH dataset_end AS (
    SELECT MAX(invoice_date) AS max_date
    FROM transactions
    WHERE invoice NOT LIKE 'C%'
),
customer_metrics AS (
    SELECT 
        customer_id,
        (SELECT max_date FROM dataset_end) - MAX(invoice_date) AS recency_days,
        COUNT(DISTINCT invoice) AS frequency,
        SUM(quantity * price) AS monetary_value
    FROM transactions
    WHERE invoice NOT LIKE 'C%' 
        AND customer_id IS NOT NULL
    GROUP BY customer_id
),
rfm_scores AS (
    SELECT 
        customer_id,
        recency_days,
        frequency,
        monetary_value,
        NTILE(5) OVER (ORDER BY recency_days ASC) AS recency_score,
        NTILE(5) OVER (ORDER BY frequency) AS frequency_score,
        NTILE(5) OVER (ORDER BY monetary_value) AS monetary_score
    FROM customer_metrics
)
SELECT 
    customer_id,
    recency_days,
    frequency,
    ROUND(monetary_value, 2) AS monetary_value,
    recency_score,
    frequency_score,
    monetary_score,
    CASE 
        WHEN recency_score >= 4 AND frequency_score >= 4 THEN 'Champions'
        WHEN recency_score >= 3 AND frequency_score >= 3 THEN 'Loyal Customers'
        WHEN recency_score >= 4 AND frequency_score <= 2 THEN 'Promising'
        WHEN recency_score <= 2 AND frequency_score >= 3 THEN 'At Risk'
        WHEN recency_score <= 2 AND frequency_score <= 2 THEN 'Lost'
        ELSE 'Regular'
    END AS customer_segment
FROM rfm_scores
ORDER BY monetary_value DESC