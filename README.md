# HR Employee Attrition Analysis

Analysis of a 320-employee HR dataset to identify key drivers of employee attrition, using Excel, SQL, and Power BI.

## Project Overview
This project simulates a real-world HR analytics workflow: clean and explore data, answer business questions with SQL, and present findings through an interactive Power BI dashboard.

## Tools Used
- **Excel** — Data exploration using COUNTIFS, AVERAGEIFS, conditional formatting, and charts
- **SQL** — Joins, aggregate functions, CASE statements, and window functions (RANK)
- **Power BI** — DAX measures, KPI cards, slicers, interactive dashboard

## Files
| File | Description |
|------|-------------|
| `HR_Employee_Attrition.csv` | Raw dataset (320 employee records) |
| `HR_Attrition_Analysis.xlsx` | Excel workbook with formulas, pivot-style summary tables, and charts |
| `HR_Attrition_Analysis.sql` | SQL schema and analysis queries |
| `HR_Attrition_Dashboard.pbix` | Power BI dashboard file |
| `dashboard_screenshot.png` | Preview image of the Power BI dashboard |

## Key Insights
- Employees working overtime had a **25% attrition rate** vs. **16%** for those who didn't.
- Attrition rate decreased steadily as job satisfaction increased (1 = lowest, 4 = highest).
- Sales and HR departments showed the highest attrition rates; Customer Support had the lowest.

## Dashboard Preview
*(Add a screenshot of your Power BI dashboard here once built)*

## How to Use
1. Open `HR_Attrition_Analysis.xlsx` to see the Excel-based analysis.
2. Run `HR_Attrition_Analysis.sql` against the CSV (imported into MySQL/PostgreSQL) to reproduce the queries.
3. Open `HR_Attrition_Dashboard.pbix` in Power BI Desktop to explore the interactive dashboard.

## Author
**Akash S**
[GitHub](https://github.com/Akash13351)
