#  Inventory Management System — Database Design & Implementation

![Database](https://img.shields.io/badge/Database-Oracle-F80000?style=flat-square&logo=oracle&logoColor=white)
![PL/SQL](https://img.shields.io/badge/PL%2FSQL-Procedures%20%26%20Triggers-blue?style=flat-square)
![Status](https://img.shields.io/badge/Status-Complete-brightgreen?style=flat-square)
![License](https://img.shields.io/badge/License-Academic-lightgrey?style=flat-square)

A fully normalized relational database system for managing inventory operations — built as a database systems group project. The project covers the complete lifecycle of database design: conceptual modeling, logical modeling, normalization, and physical implementation with triggers, stored procedures, and views.


##  Overview

This project models a real-world inventory management workflow — covering suppliers, products, warehouses, stock movement, purchase orders, and sales — using a properly normalized relational schema. Rather than just designing tables, the project implements active database logic (triggers for stock updates, stored procedures for common operations, and views for reporting) so the database enforces business rules itself instead of relying on application code.

##  Key Features

- **12 normalized entities** designed through conceptual (ER) and logical modeling, taken through normalization (up to 3NF/BCNF) to eliminate redundancy
- **Triggers** for automated stock-level updates and data integrity enforcement (e.g. updating inventory counts on transaction events)
- **Stored procedures** for common operational tasks (e.g. processing orders, restocking, generating reports)
- **Views** for simplified reporting and querying across joined tables
- **Indexes** added on high-traffic columns to optimize query performance
- **Complex queries** demonstrating multi-table joins, aggregations, and subqueries for real inventory reporting needs

##  Repository Structure

```
inventory-management-system/
├── README.md
├── sql/
│   ├── 01_schema.sql              # Table definitions, keys, constraints
│   ├── 02_triggers.sql            # Trigger definitions
│   ├── 03_stored_procedures.sql   # Stored procedure definitions
│   ├── 04_views_and_indexex.sql   # View definitions
│   └── 05_sample_queries.sql      # Example complex queries
├── docs/
│   └── technical_report.pdf       # Full data modeling & implementation report
└── diagrams/
    └── er_diagram.png             # Conceptual ER diagram
```

## Tech Stack

- **Database:** Oracle Database (PL/SQL)
- **Concepts applied:** ER modeling, normalization, triggers, stored procedures, views, indexing

##  Getting Started

Run the scripts in order using **SQL\*Plus** or **SQL Developer**, connected to your Oracle schema/user:

```bash
# 1. Create the schema
sqlplus username/password@your_db @sql/01_schema.sql

# 2. Add triggers
sqlplus username/password@your_db @sql/02_triggers.sql

# 3. Add stored procedures
sqlplus username/password@your_db @sql/03_stored_procedures.sql

# 4. Add views
sqlplus username/password@your_db @sql/04_views.sql

# 5. Run sample queries
sqlplus username/password@your_db @sql/05_sample_queries.sql
```

> Alternatively, open each `.sql` file in **Oracle SQL Developer** and run as a script (F5).

##  Documentation

The full technical report — covering the conceptual data model, ER diagrams, normalization steps, and implementation details — is available in [`docs/technical_report.pdf`](docs/technical_report.pdf).

## 📌 Notes

This was developed as an academic database systems project, with emphasis on correct relational design and demonstrating active database features (triggers/procedures/views) rather than a front-end application.
