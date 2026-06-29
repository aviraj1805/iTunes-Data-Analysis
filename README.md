# iTunes Music Store - Data Analysis Project

## Overview

This project is a comprehensive SQL-based data analysis of the Apple iTunes Music Store database, completed as part of a data analytics internship. The analysis explores customer behavior, sales performance, product popularity, and geographic revenue distribution across a relational database containing 11 interconnected tables.

The goal is to extract actionable business insights using structured SQL queries — ranging from basic aggregations to advanced window functions and CTEs — and present findings through a full analytical report and presentation.

---

## Repository Structure

```
iTunes-Data-Analysis/
|
|-- iTuneMusic_Internship.sql          # Main SQL script 
|
|-- Datasets/                          # Raw CSV data files 
|   |-- artist.csv
|   |-- album.csv
|   |-- track.csv
|   |-- genre.csv
|   |-- media_type.csv
|   |-- playlist.csv
|   |-- playlist_track.csv
|   |-- employee.csv
|   |-- customer.csv
|   |-- invoice.csv
|   |-- invoice_line.csv
|
|-- iTunes_Analysis_Report_Updated.docx   # Detailed written analysis report
|-- iTunes_Analytics_Report.pptx          # Presentation of key findings
|-- README.md
```

---

## Database Schema

The database (`itunes_db`) contains 11 tables with the following relationships:

- **artist** -> **album** -> **track** (catalog hierarchy)
- **track** -> **genre**, **media_type** (track classification)
- **employee** -> **customer** -> **invoice** -> **invoice_line** (sales pipeline)
- **playlist** -> **playlist_track** -> **track** (playlist management)

All primary keys and foreign key constraints are defined in Part 1 of the SQL script.

---

## Analysis Sections

### Part 1: Database Setup
Defines all primary keys and foreign key relationships across the 11 tables to enforce referential integrity.

### Part 2: Data Exploration
- Row counts per table
- Data quality checks (null values, missing references)
- Sales date range overview
- Top-level business metrics (total customers, total revenue)

### Part 3: Customer Analysis
1. Top 10 highest-spending customers
2. Average customer lifetime value
3. Repeat buyers vs. one-time buyers
4. Revenue per customer segmented by country
5. Customers with no recent purchases (last 6 months)

### Part 4: Sales and Revenue Analysis
1. Monthly revenue trends
2. Yearly revenue comparison
3. Average, minimum, and maximum invoice values
4. Sales representative performance by revenue
5. Best performing countries by total revenue

### Part 5: Product Analysis (Tracks, Artists, Albums)
1. Most popular genres by sales and revenue
2. Top 10 best-selling artists
3. Top albums ranked by revenue
4. Most purchased individual tracks
5. Track length statistical analysis
6. Price point distribution across the catalog

### Part 6: Media Type Analysis
1. Revenue breakdown by media type
2. Most common media format in the library

### Part 7: Employee and Geographic Analysis
1. Employee performance: customers managed, invoices processed, revenue generated
2. Top countries by total revenue
3. Top cities by total revenue

### Part 8: Advanced Analysis (Window Functions and CTEs)
1. Global and country-level customer ranking using `RANK()`
2. Running total of monthly revenue using `SUM() OVER()`
3. Customer segmentation (High Value, Medium Value, Low Value) using CASE
4. Top artist per genre using `RANK() OVER(PARTITION BY ...)`
5. Month-over-month revenue growth percentage using `LAG()`
6. Average days between purchases per customer using `LAG()` with `DATEDIFF()`
7. Customer music taste diversity — number of unique genres purchased

---

## Tools and Technologies

| Tool | Purpose |
|---|---|
| MySQL 8.0 | Database engine and query execution |
| MySQL Workbench | Query development and schema visualization |
| Microsoft Word | Written analysis report |
| Microsoft PowerPoint | Presentation of findings |

---

## How to Run

1. Import all CSV files from the `Datasets/` folder into a MySQL database named `itunes_db`. Each CSV file corresponds to a table of the same name.

2. Open `iTuneMusic_Internship.sql` in MySQL Workbench or any compatible MySQL client.

3. Execute the script sequentially — Part 1 must run first to set up keys before the analysis queries in Parts 2–8 will work correctly.

> Ensure the MySQL server version is 8.0 or higher. Window functions (`RANK()`, `LAG()`, `SUM() OVER()`) used in Part 8 are not supported in earlier versions.

---

## Key Findings

- **USA** is the top revenue-generating country, followed by Canada and Brazil.
- **Rock** is the highest-grossing genre by a significant margin.
- The majority of customers are repeat buyers, indicating strong retention.
- A small segment of high-value customers contributes disproportionately to total revenue.
- Revenue shows consistent growth year-over-year with seasonal variation at a monthly level.

---

## Dataset Source

The iTunes Music Store dataset is a widely used sample database originally distributed with the [Chinook Database](https://github.com/lerocha/chinook-database) project. It models a digital media store and is commonly used for SQL learning and practice.

---

## Author
### Aviraj Virape
**Internship Project — Data Analytics**  
Apple iTunes Music Store Database Analysis  
Completed: March 2026
