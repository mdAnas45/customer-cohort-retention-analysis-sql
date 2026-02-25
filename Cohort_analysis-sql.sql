--Creating table

CREATE TABLE online_retail (
    invoice_no VARCHAR(20),
    stock_code VARCHAR(20),
    description TEXT,
    quantity INTEGER,
    invoice_date TIMESTAMP,
    unit_price NUMERIC(10,2),
    customer_id NUMERIC,
    country VARCHAR(100)
);
--filtering not null value

SELECT 
    customer_id,
    MIN(invoice_date) AS first_purchase_date
FROM online_retail
WHERE customer_id IS NOT NULL
GROUP BY customer_id
ORDER BY customer_id;


--first purchase date
SELECT 
    customer_id,
    DATE_TRUNC('month', MIN(invoice_date)) AS cohort_month
FROM online_retail
WHERE customer_id IS NOT NULL
GROUP BY customer_id
ORDER BY customer_id;

--every transaction with cohort month


WITH cohort AS (
    SELECT 
        customer_id,
        DATE_TRUNC('month', MIN(invoice_date)) AS cohort_month
    FROM online_retail
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
)

SELECT 
    o.customer_id,
    cohort.cohort_month,
    DATE_TRUNC('month', o.invoice_date) AS purchase_month
FROM online_retail o
JOIN cohort 
    ON o.customer_id = cohort.customer_id
WHERE o.customer_id IS NOT NULL
ORDER BY o.customer_id;


--Month index
WITH cohort AS (
    SELECT 
        customer_id,
        DATE_TRUNC('month', MIN(invoice_date)) AS cohort_month
    FROM online_retail
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
),
cohort_data AS (
    SELECT 
        o.customer_id,
        cohort.cohort_month,
        DATE_TRUNC('month', o.invoice_date) AS purchase_month
    FROM online_retail o
    JOIN cohort 
        ON o.customer_id = cohort.customer_id
    WHERE o.customer_id IS NOT NULL
)

SELECT
    customer_id,
    cohort_month,
    purchase_month,
    (DATE_PART('year', purchase_month) - DATE_PART('year', cohort_month)) * 12 +
    (DATE_PART('month', purchase_month) - DATE_PART('month', cohort_month))
    AS month_index
FROM cohort_data
ORDER BY customer_id, purchase_month;



--Inspection 

WITH cohort AS (
    SELECT 
        customer_id,
        DATE_TRUNC('month', MIN(invoice_date)) AS cohort_month
    FROM online_retail
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
),
cohort_data AS (
    SELECT 
        o.customer_id,
        cohort.cohort_month,
        DATE_TRUNC('month', o.invoice_date) AS purchase_month,
        (DATE_PART('year', DATE_TRUNC('month', o.invoice_date)) 
         - DATE_PART('year', cohort.cohort_month)) * 12 +
        (DATE_PART('month', DATE_TRUNC('month', o.invoice_date)) 
         - DATE_PART('month', cohort.cohort_month)) AS month_index
    FROM online_retail o
    JOIN cohort 
        ON o.customer_id = cohort.customer_id
    WHERE o.customer_id IS NOT NULL
)

SELECT
    cohort_month,
    month_index,
    COUNT(DISTINCT customer_id) AS customer_count
FROM cohort_data
GROUP BY cohort_month, month_index
ORDER BY cohort_month, month_index;


--Inspection 

WITH cohort AS (
    SELECT 
        customer_id,
        DATE_TRUNC('month', MIN(invoice_date)) AS cohort_month
    FROM online_retail
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
),
cohort_data AS (
    SELECT 
        o.customer_id,
        cohort.cohort_month,
        DATE_TRUNC('month', o.invoice_date) AS purchase_month,
        (DATE_PART('year', DATE_TRUNC('month', o.invoice_date)) 
         - DATE_PART('year', cohort.cohort_month)) * 12 +
        (DATE_PART('month', DATE_TRUNC('month', o.invoice_date)) 
         - DATE_PART('month', cohort.cohort_month)) AS month_index
    FROM online_retail o
    JOIN cohort 
        ON o.customer_id = cohort.customer_id
    WHERE o.customer_id IS NOT NULL
),
cohort_counts AS (
    SELECT
        cohort_month,
        month_index,
        COUNT(DISTINCT customer_id) AS customer_count
    FROM cohort_data
    GROUP BY cohort_month, month_index
)

SELECT
    c.cohort_month,
    c.month_index,
    c.customer_count,
    ROUND(
        c.customer_count * 100.0 /
        FIRST_VALUE(c.customer_count) OVER (
            PARTITION BY c.cohort_month
            ORDER BY c.month_index
        ),
        2
    ) AS retention_percentage
FROM cohort_counts c
ORDER BY c.cohort_month, c.month_index;



--Retention privot

WITH cohort AS (
    SELECT 
        customer_id,
        DATE_TRUNC('month', MIN(invoice_date)) AS cohort_month
    FROM online_retail
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
),
cohort_data AS (
    SELECT 
        o.customer_id,
        cohort.cohort_month,
        DATE_TRUNC('month', o.invoice_date) AS purchase_month,
        (DATE_PART('year', DATE_TRUNC('month', o.invoice_date)) 
         - DATE_PART('year', cohort.cohort_month)) * 12 +
        (DATE_PART('month', DATE_TRUNC('month', o.invoice_date)) 
         - DATE_PART('month', cohort.cohort_month)) AS month_index
    FROM online_retail o
    JOIN cohort 
        ON o.customer_id = cohort.customer_id
    WHERE o.customer_id IS NOT NULL
),
cohort_counts AS (
    SELECT
        cohort_month,
        month_index,
        COUNT(DISTINCT customer_id) AS customer_count
    FROM cohort_data
    GROUP BY cohort_month, month_index
),
retention_table AS (
    SELECT
        c.cohort_month,
        c.month_index,
        c.customer_count,
        FIRST_VALUE(c.customer_count) OVER (
            PARTITION BY c.cohort_month
            ORDER BY c.month_index
        ) AS base_count
    FROM cohort_counts c
)

SELECT
    cohort_month,
    ROUND(MAX(CASE WHEN month_index = 0 THEN customer_count*100.0/base_count END),2) AS month_0,
    ROUND(MAX(CASE WHEN month_index = 1 THEN customer_count*100.0/base_count END),2) AS month_1,
    ROUND(MAX(CASE WHEN month_index = 2 THEN customer_count*100.0/base_count END),2) AS month_2,
    ROUND(MAX(CASE WHEN month_index = 3 THEN customer_count*100.0/base_count END),2) AS month_3,
    ROUND(MAX(CASE WHEN month_index = 4 THEN customer_count*100.0/base_count END),2) AS month_4,
    ROUND(MAX(CASE WHEN month_index = 5 THEN customer_count*100.0/base_count END),2) AS month_5,
    ROUND(MAX(CASE WHEN month_index = 6 THEN customer_count*100.0/base_count END),2) AS month_6,
    ROUND(MAX(CASE WHEN month_index = 7 THEN customer_count*100.0/base_count END),2) AS month_7,
    ROUND(MAX(CASE WHEN month_index = 8 THEN customer_count*100.0/base_count END),2) AS month_8,
    ROUND(MAX(CASE WHEN month_index = 9 THEN customer_count*100.0/base_count END),2) AS month_9,
    ROUND(MAX(CASE WHEN month_index = 10 THEN customer_count*100.0/base_count END),2) AS month_10,
    ROUND(MAX(CASE WHEN month_index = 11 THEN customer_count*100.0/base_count END),2) AS month_11
FROM retention_table
GROUP BY cohort_month
ORDER BY cohort_month;





--Cohort privot

WITH cohort AS (
    SELECT 
        customer_id,
        DATE_TRUNC('month', MIN(invoice_date)) AS cohort_month
    FROM online_retail
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
),
cohort_data AS (
    SELECT 
        o.customer_id,
        cohort.cohort_month,
        DATE_TRUNC('month', o.invoice_date) AS purchase_month,
        (DATE_PART('year', DATE_TRUNC('month', o.invoice_date)) 
         - DATE_PART('year', cohort.cohort_month)) * 12 +
        (DATE_PART('month', DATE_TRUNC('month', o.invoice_date)) 
         - DATE_PART('month', cohort.cohort_month)) AS month_index
    FROM online_retail o
    JOIN cohort 
        ON o.customer_id = cohort.customer_id
    WHERE o.customer_id IS NOT NULL
),
cohort_counts AS (
    SELECT
        cohort_month,
        month_index,
        COUNT(DISTINCT customer_id) AS customer_count
    FROM cohort_data
    GROUP BY cohort_month, month_index
)

SELECT
    cohort_month,
    MAX(CASE WHEN month_index = 0 THEN customer_count END) AS month_0,
    MAX(CASE WHEN month_index = 1 THEN customer_count END) AS month_1,
    MAX(CASE WHEN month_index = 2 THEN customer_count END) AS month_2,
    MAX(CASE WHEN month_index = 3 THEN customer_count END) AS month_3,
    MAX(CASE WHEN month_index = 4 THEN customer_count END) AS month_4,
    MAX(CASE WHEN month_index = 5 THEN customer_count END) AS month_5,
    MAX(CASE WHEN month_index = 6 THEN customer_count END) AS month_6,
    MAX(CASE WHEN month_index = 7 THEN customer_count END) AS month_7,
    MAX(CASE WHEN month_index = 8 THEN customer_count END) AS month_8,
    MAX(CASE WHEN month_index = 9 THEN customer_count END) AS month_9,
    MAX(CASE WHEN month_index = 10 THEN customer_count END) AS month_10,
    MAX(CASE WHEN month_index = 11 THEN customer_count END) AS month_11
FROM cohort_counts
GROUP BY cohort_month
ORDER BY cohort_month;