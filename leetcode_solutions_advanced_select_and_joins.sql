-- Advanced Select and Joins Medium Difficulty Product Price at a Given Date
-- find prices of all products on 16 Aug. Assume price of all products before any change is 10

-- Input: 
-- Products table:
-- +------------+-----------+-------------+
-- | product_id | new_price | change_date |
-- +------------+-----------+-------------+
-- | 1          | 20        | 2019-08-14  |
-- | 2          | 50        | 2019-08-14  |
-- | 1          | 30        | 2019-08-15  |
-- | 1          | 35        | 2019-08-16  |
-- | 2          | 65        | 2019-08-17  |
-- | 3          | 20        | 2019-08-18  |
-- +------------+-----------+-------------+
-- Output: 
-- +------------+-------+
-- | product_id | price |
-- +------------+-------+
-- | 2          | 50    |
-- | 1          | 35    |
-- | 3          | 10    |
-- +------------+-------+

WITH product_level_before_cutoff AS (
    SELECT 
    *
    FROM Products
    WHERE change_date <= "2019-08-16"
)

, product_level_with_latest_price AS (
    SELECT
    product_id,
    FIRST_VALUE(new_price) OVER (PARTITION BY product_id ORDER BY change_date DESC) AS latest_price,
    new_price,
    change_date
    FROM product_level_before_cutoff
)

, product_level_relevant_changes AS (
    SELECT
    product_id,
    new_price
    FROM product_level_with_latest_price
    WHERE new_price = latest_price
)

SELECT DISTINCT 
p.product_id,
IFNULL(c.new_price, 10) AS price
FROM Products p 
LEFT JOIN product_level_relevant_changes c
ON p.product_id = c.product_id


