📊 Customer Cohort & Retention Analysis (SQL)
📌 Overview

This project presents a Customer Cohort & Retention Analysis performed using PostgreSQL.

The analysis identifies customer purchasing behavior over time by grouping customers based on their first purchase month (Cohort Month) and tracking their activity in subsequent months.

It transforms raw transactional data into structured cohort tables and retention matrices to help understand customer lifecycle and repeat purchase behavior.

🎯 Project Purpose

The purpose of this analysis is to help businesses:

Track customer retention over time

Measure monthly repeat purchase behavior

Identify customer churn patterns

Compare performance of different acquisition months

Support data-driven marketing and retention strategies

🛠 Tech Stack

PostgreSQL – Data processing and cohort computation

CTEs (Common Table Expressions) – Structured query building

Window Functions (FIRST_VALUE) – Base cohort size calculation

Date Functions (DATE_TRUNC, DATE_PART) – Month-level analysis

Aggregation & Pivoting using CASE WHEN – Cohort matrix creation

📂 Data Source

Online Retail transactional dataset (portfolio demonstration)

Dataset includes:

Customer ID

Invoice Date

Transaction details

Note: Dataset used for learning and portfolio purposes.

🧠 Business Problem

Customer retention is one of the most critical metrics in e-commerce and retail businesses.

Without cohort analysis, it is difficult to:

Understand long-term customer engagement

Measure retention performance by acquisition month

Identify declining customer groups

Estimate customer lifetime behavior

📊 Analysis Approach

The SQL workflow is structured in multiple steps:

1️⃣ Cohort Identification

Each customer's first purchase month is identified:

DATE_TRUNC('month', MIN(invoice_date)) AS cohort_month

This defines the customer’s acquisition month.

2️⃣ Monthly Activity Tracking

For each transaction:

Purchase month is calculated

Month difference from cohort month is computed as:

month_index

This represents how many months after acquisition the purchase occurred.

Example:

Cohort Month	Purchase Month	Month Index
Jan 2011	Jan 2011	0
Jan 2011	Feb 2011	1
Jan 2011	Apr 2011	3
3️⃣ Cohort Size Calculation

For each:

Cohort Month

Month Index

We calculate:

COUNT(DISTINCT customer_id)

This produces the Cohort Count Matrix.

4️⃣ Retention Rate Calculation

Using window function:

FIRST_VALUE(customer_count) OVER (PARTITION BY cohort_month ORDER BY month_index)

This gets the base cohort size (Month 0).

Retention Rate formula:

(customer_count / base_count) * 100
📈 Output 1: Cohort Count Matrix

Displays number of active customers by:

Cohort Month (rows)

Month Index (columns: Month 0–Month 11)

This shows how many customers returned each month.

📉 Output 2: Retention Rate Matrix (%)

Displays percentage retention relative to Month 0.

Example structure:

Cohort	M0	M1	M2	M3
Jan 2011	100%	42%	35%	30%
Feb 2011	100%	38%	29%	25%
🔍 Key Insights

Retention typically declines month over month

Some cohorts perform better than others

Early churn is common in the first 2–3 months

Strong cohorts indicate effective acquisition channels

💡 Business Value

This cohort analysis helps businesses:

Measure customer loyalty

Evaluate marketing campaign quality

Identify churn risk early

Improve retention strategy

Estimate long-term revenue behavior

📌 Key SQL Concepts Demonstrated

CTE chaining

Date manipulation

Cohort indexing logic

Window functions

Conditional aggregation

Manual pivot table construction

🚀 Conclusion

This project demonstrates how advanced SQL techniques can be used to perform full cohort and retention analysis without BI tools.

It converts raw transactional data into actionable retention insights, enabling strategic decision-making in customer lifecycle management.

👤 Author

Anas
Aspiring Data Analyst
Excel | Power BI | SQL | Python
