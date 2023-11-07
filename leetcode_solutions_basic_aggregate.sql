-- Basic Aggregate Functions (Medium Difficulty) Monthly Transactions I
--  find for each month and country, the number of transactions and their total amount, the number of approved transactions and their total amount.

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

  
-- Basic Aggregate Functions (Medium Difficulty) Immediate Food Delivery II
  -- find the percentage of immediate orders in the first orders of all customers

WITH customer_order_level_table AS (
    SELECT
    delivery_id,
    customer_id,
    order_date,
    # CONCAT(delivery_id, "_", customer_id) AS order_uuid,
    CASE WHEN order_date = customer_pref_delivery_date THEN "immediate"
    ELSE "scheduled"
    END AS order_status,
    FIRST_VALUE(order_date) OVER (PARTITION BY customer_id ORDER BY order_date ASC) AS first_order_date
    FROM Delivery
)

, only_first_order_per_customer_table AS (
    SELECT
    customer_id,
    SUM(CASE WHEN order_status = "immediate" THEN 1 ELSE 0 END) AS immediate_orders,
    COUNT(*) AS total_orders
FROM customer_order_level_table
WHERE order_date = first_order_date
GROUP BY 1
)

SELECT 
ROUND(SUM(immediate_orders)*100/SUM(total_orders),2) AS immediate_percentage
FROM only_first_order_per_customer_table
