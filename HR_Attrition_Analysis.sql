/* ============================================================
   HR EMPLOYEE ATTRITION ANALYSIS - SQL
   Author: Akash S
   Description: Table schema + business analysis queries on the
   HR Employee Attrition dataset (320 employees).
   Tested on: MySQL 8.0 / PostgreSQL (minor syntax notes below)
   ============================================================ */

-- ---------------------------------------------------------
-- 1. TABLE CREATION
-- ---------------------------------------------------------
DROP TABLE IF EXISTS employees;

CREATE TABLE employees (
    EmployeeID              INT PRIMARY KEY,
    Name                    VARCHAR(100),
    Age                     INT,
    Gender                  VARCHAR(10),
    MaritalStatus           VARCHAR(20),
    Department              VARCHAR(50),
    JobRole                 VARCHAR(50),
    City                    VARCHAR(50),
    Education               VARCHAR(20),
    EducationField          VARCHAR(50),
    BusinessTravel          VARCHAR(30),
    TenureYears             DECIMAL(4,1),
    MonthlyIncome           INT,
    PercentSalaryHike       INT,
    JobSatisfaction         INT,        -- 1 (Low) to 4 (High)
    EnvironmentSatisfaction INT,        -- 1 (Low) to 4 (High)
    WorkLifeBalance         INT,        -- 1 (Low) to 4 (High)
    PerformanceRating       INT,        -- 1 (Low) to 4 (High)
    OverTime                VARCHAR(5), -- Yes / No
    DistanceFromHome_km     INT,
    NumCompaniesWorked      INT,
    TrainingTimesLastYear   INT,
    YearsSinceLastPromotion INT,
    Attrition               VARCHAR(5)  -- Yes / No
);

-- Import data:
-- MySQL:  LOAD DATA INFILE 'HR_Employee_Attrition.csv' INTO TABLE employees
--         FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
-- Postgres: \copy employees FROM 'HR_Employee_Attrition.csv' WITH (FORMAT csv, HEADER true);


-- ---------------------------------------------------------
-- 2. BASIC EXPLORATION
-- ---------------------------------------------------------

-- 2.1 Total employees and overall attrition rate
SELECT
    COUNT(*)                                            AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)  AS total_attritions,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate_pct
FROM employees;

-- 2.2 Headcount by department
SELECT Department, COUNT(*) AS headcount
FROM employees
GROUP BY Department
ORDER BY headcount DESC;


-- ---------------------------------------------------------
-- 3. ATTRITION ANALYSIS
-- ---------------------------------------------------------

-- 3.1 Attrition rate by department (highest risk first)
SELECT
    Department,
    COUNT(*)                                            AS headcount,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)  AS attritions,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate_pct
FROM employees
GROUP BY Department
ORDER BY attrition_rate_pct DESC;

-- 3.2 Attrition rate by job role (top 5 highest-risk roles)
SELECT
    JobRole,
    COUNT(*)                                            AS headcount,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)  AS attritions,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate_pct
FROM employees
GROUP BY JobRole
ORDER BY attrition_rate_pct DESC
LIMIT 5;

-- 3.3 Does overtime increase attrition risk?
SELECT
    OverTime,
    COUNT(*)                                            AS headcount,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)  AS attritions,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate_pct
FROM employees
GROUP BY OverTime;

-- 3.4 Attrition rate by job satisfaction level
SELECT
    JobSatisfaction,
    COUNT(*)                                            AS headcount,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)  AS attritions,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate_pct
FROM employees
GROUP BY JobSatisfaction
ORDER BY JobSatisfaction;

-- 3.5 Attrition rate by tenure bucket (early-career risk check)
SELECT
    CASE
        WHEN TenureYears < 1  THEN '0-1 yr'
        WHEN TenureYears < 3  THEN '1-3 yrs'
        WHEN TenureYears < 7  THEN '3-7 yrs'
        ELSE '7+ yrs'
    END AS tenure_bucket,
    COUNT(*)                                            AS headcount,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)  AS attritions,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate_pct
FROM employees
GROUP BY tenure_bucket
ORDER BY MIN(TenureYears);


-- ---------------------------------------------------------
-- 4. COMPENSATION ANALYSIS
-- ---------------------------------------------------------

-- 4.1 Average monthly income: attrited vs retained employees, by department
SELECT
    Department,
    ROUND(AVG(CASE WHEN Attrition = 'No'  THEN MonthlyIncome END), 0) AS avg_income_retained,
    ROUND(AVG(CASE WHEN Attrition = 'Yes' THEN MonthlyIncome END), 0) AS avg_income_attrited
FROM employees
GROUP BY Department
ORDER BY Department;

-- 4.2 Employees earning below department average who are still with the company
--     (useful for flagging retention/pay-equity risk)
SELECT e.EmployeeID, e.Name, e.Department, e.MonthlyIncome
FROM employees e
JOIN (
    SELECT Department, AVG(MonthlyIncome) AS dept_avg_income
    FROM employees
    GROUP BY Department
) d ON e.Department = d.Department
WHERE e.MonthlyIncome < d.dept_avg_income
  AND e.Attrition = 'No'
ORDER BY e.Department, e.MonthlyIncome;


-- ---------------------------------------------------------
-- 5. RISK SEGMENTATION
-- ---------------------------------------------------------

-- 5.1 High-risk current employees: still employed, but overtime + low satisfaction
--     + below department average pay (a simple "watch list" for HR)
SELECT
    e.EmployeeID, e.Name, e.Department, e.JobRole,
    e.OverTime, e.JobSatisfaction, e.MonthlyIncome
FROM employees e
JOIN (
    SELECT Department, AVG(MonthlyIncome) AS dept_avg_income
    FROM employees
    GROUP BY Department
) d ON e.Department = d.Department
WHERE e.Attrition = 'No'
  AND e.OverTime = 'Yes'
  AND e.JobSatisfaction <= 2
  AND e.MonthlyIncome < d.dept_avg_income
ORDER BY e.Department;

-- 5.2 Rank departments by attrition rate using a window function
SELECT
    Department,
    attrition_rate_pct,
    RANK() OVER (ORDER BY attrition_rate_pct DESC) AS attrition_rank
FROM (
    SELECT
        Department,
        ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate_pct
    FROM employees
    GROUP BY Department
) dept_summary
ORDER BY attrition_rank;

-- 5.3 Years since last promotion vs attrition (are overlooked employees leaving?)
SELECT
    YearsSinceLastPromotion,
    COUNT(*)                                            AS headcount,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)  AS attritions,
    ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate_pct
FROM employees
GROUP BY YearsSinceLastPromotion
ORDER BY YearsSinceLastPromotion;
