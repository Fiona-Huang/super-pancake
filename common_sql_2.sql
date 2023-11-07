-- To aggregate by segment and region using cartesian join which should be cautiously used because it can generate extremely large result sets
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
