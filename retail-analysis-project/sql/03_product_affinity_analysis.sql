-- Market Basket Analysis: Holiday shopping patterns (December 2011)
-- Performance optimization: Composite index on (invoice_date, invoice, stock_code)
WITH filtered_transactions AS (
    SELECT 
        invoice,
        stock_code,
        description
    FROM transactions
    WHERE invoice NOT LIKE 'C%'
        AND description IS NOT NULL
        AND invoice_date BETWEEN '2011-12-01' AND '2011-12-31'
),
product_pairs AS (
    SELECT 
        t1.description AS product_a,
        t2.description AS product_b
    FROM filtered_transactions t1
    JOIN filtered_transactions t2 
        ON t1.invoice = t2.invoice 
        AND t1.stock_code < t2.stock_code
)
SELECT 
    product_a,
    product_b,
    COUNT(*) AS times_bought_together
FROM product_pairs
GROUP BY product_a, product_b
HAVING COUNT(*) >= 15
ORDER BY times_bought_together DESC
LIMIT 20;