-- using window function first_value
WITH sale_level_first_year_sold AS (
    SELECT
    sale_id,
    year,
    FIRST_VALUE(year) OVER (PARTITION BY product_id ORDER BY year ASC) AS first_year_sold
    FROM Sales
)

SELECT
Sales.product_id,
sale_level_first_year_sold.first_year_sold AS first_year,
Sales.quantity,
Sales.price
FROM sale_level_first_year_sold 
LEFT JOIN Sales USING (sale_id, year)
WHERE sale_level_first_year_sold.first_year_sold = Sales.year
AND sale_level_first_year_sold.sale_id = Sales.sale_id


-- using having
SELECT customer_id 
FROM Customer
GROUP BY customer_id
HAVING COUNT(DISTINCT(product_key)) = (SELECT COUNT(product_key) FROM Product)

  
-- case when and scenario
SELECT
s.user_id,
CASE WHEN c.user_id IS NULL
THEN 0.00
ELSE ROUND(SUM(c.action = 'confirmed')/COUNT(action),2)
END AS confirmation_rate
FROM Signups s
LEFT JOIN Confirmations c ON c.user_id = s.user_id
GROUP BY s.user_id

  
-- top 3 salary
WITH ranked_salary_employee_level AS (
    SELECT
    id,
    name,
    salary,
    departmentId,
    DENSE_RANK() OVER (PARTITION BY departmentId ORDER BY salary DESC) AS salary_rank
    FROM Employee
)

SELECT 
d.name AS Department,
r.name AS Employee,
r.salary AS Salary
FROM ranked_salary_employee_level r
LEFT JOIN Department d
ON r.departmentId = d.id
WHERE r.salary_rank <= 3

  
-- sum scenarios within a cte
SELECT
DATE_FORMAT(trans_date, '%Y-%m') AS month,
country,
COUNT(DISTINCT(id)) AS trans_count,
SUM(IF(state = 'approved',1, 0)) AS approved_count,
SUM(amount) AS trans_total_amount,
SUM(CASE WHEN state = 'approved' THEN amount ELSE 0 END)AS approved_total_amount
FROM Transactions
GROUP BY month, country

  
-- Get Date differences
DATEDIFF(year, ‘2022-01-01', ‘2022-01-02')
DATEDIFF(day, ‘2022-01-01', ‘2022-01-02')

  
-- build own table
WITH account_level_with_salary_category AS (
    SELECT
    account_id,
    income,
    CASE WHEN income < 20000 THEN "Low Salary"
    WHEN income >= 20000 AND income <= 50000 THEN "Average Salary"
    ELSE "High Salary"
    END AS category
    FROM Accounts
)

, salary_category_by_account_counts AS (
    SELECT
    category,
    COUNT(DISTINCT(account_id)) AS accounts_count
    FROM account_level_with_salary_category
    GROUP BY 1
)

, salary_category_table AS (
    SELECT
    "Low Salary" AS category
    UNION ALL 
    SELECT
    "Average Salary" AS category
    UNION ALL 
    SELECT
    "High Salary" AS category
)

SELECT
a.category,
IFNULL(b.accounts_count,0) AS accounts_count
FROM salary_category_table a
LEFT JOIN salary_category_by_account_counts b USING (category)

  
-- cartesian join
WITH segment_region_counts AS (
  SELECT
  segment,
  region,
  COUNT(DISTINCT(customer_id)) AS customers
  FROM user_segmentation_table
  GROUP BY segment,region
)

, total AS (
  SELECT 
COUNT(DISTINCT(pd_customer_uuid)) AS all_customers
FROM user_segmentation_table
)

, summary AS (
  SELECT DISTINCT
segment_region_counts.*,
all_customers
FROM segment_region_counts
LEFT JOIN total ON 1=1
)

SELECT 
segment,
region,
round(customers*100/all_customers,2) AS percentage
FROM summary
