-- Basic Aggregate Functions (Medium Difficulty) Monthly Transactions I

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

-- Get top country with orders
SELECT 
*
FROM (
  SELECT 
  orders.date,
  orders.country,
  order_count,
  FIRST_VALUE(order_count) OVER (PARTITION BY date, country ORDER BY order_count DESC) AS top_order
  FROM orders
  )
WHERE order_count = top_order
