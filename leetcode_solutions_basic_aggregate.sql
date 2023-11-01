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

-- Basic Aggregate Functions (Medium Difficulty) Immediate Food Delivery II
