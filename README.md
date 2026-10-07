# SQL Dimensional Report

A MySQL-based e-commerce analytics project demonstrating dimensional modeling, window functions, CTE-based Month-over-Month (MoM) growth analysis, ROLLUP reporting, and query optimization using EXPLAIN.

## Project Overview

This project uses a simple **star schema** to analyze e-commerce sales data and generate business-oriented reports.

The project focuses on:

- Dimensional modeling using fact and dimension tables
- Product and customer ranking using window functions
- Monthly sales and MoM growth analysis using CTEs
- Category and overall totals using `ROLLUP`
- Query execution analysis using `EXPLAIN`
- Basic query optimization using indexes

## Database Schema

The project uses the following tables:

- `fact_sales` – Central sales transaction table
- `dim_product` – Product information
- `dim_category` – Product categories
- `dim_customer` – Customer information
- `dim_date` – Date and time-related information

### Star Schema

```text
                 dim_category
                      |
                      |
dim_customer ---- fact_sales ---- dim_product
                      |
                      |
                   dim_date
```

## SQL Concepts Covered

- Star schema / dimensional modeling
- `RANK()`
- `DENSE_RANK()`
- `ROW_NUMBER()`
- `NTILE()`
- `LAG()`
- `LEAD()`
- Common Table Expressions (`CTE`)
- Month-over-Month (MoM) growth
- `ROLLUP`
- `EXPLAIN`
- Indexing for query optimization
- Aggregate functions
- `JOIN` operations
- `GROUP BY`

## Project Structure

```text
SQL-Dimensional-Report/
│
├── schema and data.sql
├── queries.sql
└── README.md
```

### schema and data.sql

Contains the database, star-schema tables, relationships, constraints, and sample sales data.

### queries.sql

Contains SQL queries covering window-function reports, MoM growth analysis, ROLLUP reports, and EXPLAIN-based optimization.

## Technologies

- MySQL
- MySQL Workbench
- SQL
- Git & GitHub

## How to Run

1. Open MySQL Workbench and connect to your MySQL server.
2. Run `schema and data.sql`.
3. Select the database:

```sql
USE dimensional_report_db;
```

4. Open and execute the queries from `queries.sql`.

## Key Objectives

- Understand dimensional modeling and star schemas
- Apply window functions for analytical reporting
- Calculate monthly sales growth using CTEs
- Generate hierarchical totals using `ROLLUP`
- Analyze query execution using `EXPLAIN`
- Apply basic SQL optimization techniques
