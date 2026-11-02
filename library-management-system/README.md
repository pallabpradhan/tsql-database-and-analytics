# Library Management System (SQL Server)

A relational database for managing books, members, loans and overdue fines, built with **Microsoft SQL Server (T-SQL)**.

## Features
- Normalized schema (5 tables) with primary/foreign keys, `CHECK`, `UNIQUE` and `DEFAULT` constraints
- `sp_IssueBook`: issues a book for 14 days, blocks issue when no copies are left, uses transactions
- `sp_ReturnBook`: marks return, restores stock, auto-calculates a fine of Rs.5 per overdue day
- `vw_OverdueLoans`: live view of overdue loans with estimated fines
- Analytical queries using `JOIN`, `GROUP BY`, `LEFT JOIN`, window functions

## Schema
`Categories` 1—N `Books` 1—N `Loans` N—1 `Members`, and `Loans` 1—N `Fines`

## How to run
Run the scripts in SSMS in this order:
1. `01_schema.sql`
2. `02_procedures_views.sql`
3. `03_sample_data.sql`
4. `04_queries.sql`

## Skills demonstrated
Database design, normalization, constraints, indexing, stored procedures, transactions, error handling (`TRY...CATCH`), views, joins, aggregation, window functions.
