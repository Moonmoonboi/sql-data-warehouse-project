# SQL Data Warehouse & Analytics Project

A portfolio project that builds a modern data warehouse in SQL Server using the **Medallion Architecture** (Bronze → Silver → Gold), then layers exploratory and advanced SQL analytics on top of it. It covers the full pipeline: ingesting raw CRM and ERP source files, cleaning and standardizing the data, modeling it into a star schema, and querying it for business insights.

## Architecture

The warehouse is organized into three layers, each implemented as its own SQL schema.

```
Source Systems          Bronze                Silver                  Gold
(CSV files)         (raw, as-is)      (cleaned, standardized)   (business-ready)
─────────────       ─────────────      ─────────────────────    ─────────────────
CRM exports    ──▶  bronze.crm_*  ──▶  silver.crm_*        ──▶  gold.dim_customers
ERP exports    ──▶  bronze.erp_*  ──▶  silver.erp_*        ──▶  gold.dim_products
                                                             ──▶  gold.fact_sales
```

- **Bronze** — raw data loaded as-is from source CSV files via `BULK INSERT`, no transformations.
- **Silver** — cleaned, deduplicated, and standardized data (consistent types, resolved codes, trimmed text).
- **Gold** — business-ready views modeled as a star schema (fact + dimension tables) for reporting and analytics.

### Data model (Gold layer)

- `gold.dim_customers` — customer attributes, merged from CRM and ERP sources (CRM is the source of truth for gender, falling back to ERP).
- `gold.dim_products` — current product catalog with category and subcategory enrichment (historical/expired products filtered out).
- `gold.fact_sales` — sales transactions linked to customers and products via surrogate keys.

## Repository structure

```
├── datasets/
│   ├── source_crm/          # Raw CRM CSV exports (customers, products, sales)
│   ├── source_erp/          # Raw ERP CSV exports (customer demographics, location, category)
│   ├── flat-files/          # Flattened dimension/fact CSVs for analytics tooling
│   └── DataWarehouseAnalytics.bak   # SQL Server database backup
├── scripts/
│   ├── init_database.sql        # Creates the DataWarehouse database and Bronze/Silver/Gold schemas
│   ├── bronze/
│   │   ├── ddl_bronze.sql       # Bronze table definitions
│   │   └── proc_load_bronze.sql # Loads source CSVs into Bronze via BULK INSERT
│   ├── silver/
│   │   ├── ddl_silver.sql       # Silver table definitions
│   │   └── proc_load_silver.sql # Cleans/transforms Bronze data into Silver
│   └── gold/
│       └── ddl_gold.sql         # Gold layer views (star schema)
├── Analyses/
│   ├── Exploratory_analysis.sql # Data exploration (schema, ranges, distinct values, etc.)
│   └── advanced_analysis.sql    # Trend, cumulative, and performance analysis
└── LICENSE
```

## Prerequisites

- SQL Server (2019+ recommended) or Azure SQL
- SQL Server Management Studio (SSMS) or another SQL client
- The CSV files in `datasets/source_crm/` and `datasets/source_erp/`, accessible from the machine running the load procedures

## Setup

1. **Create the database and schemas**

   Run `scripts/init_database.sql`. This drops and recreates a `DataWarehouse` database and creates the `Bronze`, `Silver`, and `Gold` schemas.

   > ⚠️ This script drops the `DataWarehouse` database if it already exists. Back up first if you have existing data there.

2. **Create the Bronze tables**

   Run `scripts/bronze/ddl_bronze.sql`.

3. **Load the Bronze layer**

   Run `scripts/bronze/proc_load_bronze.sql` to create the `bronze.load_bronze` stored procedure, then execute it:

   ```sql
   EXEC bronze.load_bronze;
   ```

   > The `BULK INSERT` file paths in this script are currently hardcoded to a local Windows path. Update them to point at your local copy of `datasets/source_crm/` and `datasets/source_erp/` before running.

4. **Create and load the Silver layer**

   Run `scripts/silver/ddl_silver.sql`, then `scripts/silver/proc_load_silver.sql` to create the `silver.load_silver` procedure, and execute it:

   ```sql
   EXEC silver.load_silver;
   ```

5. **Create the Gold layer**

   Run `scripts/gold/ddl_gold.sql` to create the `gold.dim_customers`, `gold.dim_products`, and `gold.fact_sales` views.

## Usage

Once the Gold layer views are in place, query them directly for reporting and analysis:

```sql
SELECT TOP 10 * FROM gold.fact_sales;
SELECT * FROM gold.dim_customers WHERE country = 'Canada';
```

The `Analyses/` folder contains ready-to-run examples:

- **`Exploratory_analysis.sql`** — explore the database schema, date ranges, distinct categories/countries, and customer demographics.
- **`advanced_analysis.sql`** — sales trends over time, running totals, and product/customer performance analysis. Intended to be run block by block rather than all at once.

## Notes

- Re-running `proc_load_bronze.sql` / `proc_load_silver.sql` truncates and reloads the target tables — safe to re-run as source data changes.
- This repository is uploaded in stages, so scripts and datasets are added incrementally. Directory structure above will fill in as new pieces are pushed.

## License

Released under the [MIT License](LICENSE).
