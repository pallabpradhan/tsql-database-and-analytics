# E-Commerce Sales Analytics (SQL Server)

A sales database plus a set of business-analytics queries, written in **Microsoft SQL Server (T-SQL)**.

## What it answers
- Monthly revenue and month-over-month growth
- Top customers and customer segments (Gold / Silver / Bronze)
- Best-selling product in each category
- Products that never sold
- Running revenue total and repeat customers

## Schema
`Customers` 1—N `Orders` 1—N `OrderItems` N—1 `Products`

## How to run
Run in SSMS in this order:
1. `01_schema.sql`
2. `02_sample_data.sql`
3. `03_analytics_queries.sql`

## Skills demonstrated
Schema design, constraints, indexing, multi-table joins, CTEs, window functions (`RANK`, `ROW_NUMBER`, `LAG`, running totals), `CASE`, `HAVING`, `NULLIF`/`COALESCE`.
