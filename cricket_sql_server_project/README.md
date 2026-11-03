# Real-Time Cricket Analytics Engine (Python + Microsoft SQL Server)

A production-structured Cricket Match & Player Analytics backend built with **Python (`pyodbc`)** and **Microsoft SQL Server (T-SQL)**.

## Key Engineering Highlights
1. **SQL Injection Prevention**: Every SQL query and Stored Procedure call uses parameterized `?` placeholders via `pyodbc`, ensuring malicious inputs (such as `' OR 1=1; DROP TABLE dbo.Players; --`) are treated strictly as literal values rather than executable T-SQL commands.
2. **ACID Transactions**: Ball-by-ball updates execute inside `dbo.sp_RecordDelivery` with `BEGIN TRANSACTION`, `COMMIT`, and `ROLLBACK` blocks.
3. **Database-Side Aggregation**: Batting strike rates, boundary counts, bowling economy rates, and required run rates are aggregated directly inside SQL Server.

## Project Structure
```
cricket_sql_server_project/
├── sql/
│   └── 01_schema_and_procedures.sql   # T-SQL script to create DB, tables, seed data & stored procedures
├── src/
│   ├── __init__.py
│   ├── db_config.py                   # Connection manager loading credentials from .env
│   └── cricket_repository.py          # Parameterized SQL queries & stored procedure calls
├── tests/
│   └── test_sql_injection_safety.py   # Automated unit tests verifying SQL injection protection
├── .env.example                       # Environment variable template
├── requirements.txt                   # Python dependencies
├── main.py                            # Live match simulation & analytics runner
└── README.md                          # Documentation
```

## Quick Start Guide

### 1. Set Up Microsoft SQL Server
1. Open **SQL Server Management Studio (SSMS)**.
2. Open and execute `sql/01_schema_and_procedures.sql` to create `CricketAnalyticsDB`, tables, sample players, and the `sp_RecordDelivery` stored procedure.

### 2. Configure Python Environment
```bash
pip install -r requirements.txt
cp .env.example .env
```
Edit `.env` to match your local SQL Server instance name (e.g., `localhost\SQLEXPRESS` or `localhost`).

### 3. Run the Application
```bash
python main.py
```

### 4. Run Unit Tests (No DB connection required)
```bash
python -m unittest discover -s tests
```
