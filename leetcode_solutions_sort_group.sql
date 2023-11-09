-- Product Sales Analysis III
-- Table: Sales

-- +-------------+-------+
-- | Column Name | Type  |
-- +-------------+-------+
-- | sale_id     | int   |
-- | product_id  | int   |
-- | year        | int   |
-- | quantity    | int   |
-- | price       | int   |
-- +-------------+-------+
-- (sale_id, year) is the primary key (combination of columns with unique values) of this table.
-- product_id is a foreign key (reference column) to Product table.
-- Each row of this table shows a sale on the product product_id in a certain year.
-- Note that the price is per unit.
 

-- Table: Product

-- +--------------+---------+
-- | Column Name  | Type    |
-- +--------------+---------+
-- | product_id   | int     |
-- | product_name | varchar |
-- +--------------+---------+
-- product_id is the primary key (column with unique values) of this table.
-- Each row of this table indicates the product name of each product.

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


-- Customers Who Bought All Products
-- Table: Customer

-- +-------------+---------+
-- | Column Name | Type    |
-- +-------------+---------+
-- | customer_id | int     |
-- | product_key | int     |
-- +-------------+---------+
-- This table may contain duplicates rows. 
-- customer_id is not NULL.
-- product_key is a foreign key (reference column) to Product table.
 

-- Table: Product

-- +-------------+---------+
-- | Column Name | Type    |
-- +-------------+---------+
-- | product_key | int     |
-- +-------------+---------+
-- product_key is the primary key (column with unique values) for this table.

SELECT customer_id 
FROM Customer
GROUP BY customer_id
HAVING COUNT(DISTINCT(product_key)) = (SELECT COUNT(product_key) FROM Product)
