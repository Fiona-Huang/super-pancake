-- What does this showcase:

-- 1. remove the need for changing dates throughout code ctes by declaring only once at the top of code
-- 2. use of subquery only when necessary, in this case, a small cte where we remove users who were errorneously assigned to control and variation for A/B testing
-- 3. usage of lower() to take in different values ANDROID, Android, android
-- 4. usage of analytics/window function to apply aggregate function without actually aggregating, since the number of rows stay the same to get each user_id
--    with their total_variant_per_user

DECLARE start_date DATE DEFAULT '2023-01-01'
DECLARE end_date DATE DEFAULT '2023-06-01'

SELECT * FROM (
  SELECT
  test_id,
  variant,
  user_id,
  COUNT(DISTINCT(variant)) OVER (PARTITION BY user_id, country) AS total_variant_per_user
  FROM assignment_table
  WHERE assignment_date BETWEEN start_date AND end_date
  AND test_id = "super_pancake_test"
  AND (LOWER(client) IN ("android") AND (REGEXP_CONTAINS(app_version, "^23.1") OR (REGEXP_CONTAINS(app_version, "23.2"))))
  AND (LOWER(client) IN ("ios") AND (REGEXP_CONTAINS(app_version, "23.2")))
  AND regexp_contains(app_version, "^23.1")
)
WHERE total_variant_per_user = 1


-- aggregation from events level to session level
WITH session_funnel AS (
  SELECT
  country,
  region,
  platform,
  session_id,
  menu_page_loaded > 0 AS stage_1, --returns boolean false/true
  product_page_loaded > 0 AS stage_2,
  cart_page_loaded > 0 AS stage_3,
  checkout_page_loaded > 0 AS stage_4,
  transaction_page_loaded > 0 AS final_stage,
FROM session_level_table_1
WHERE date_utc BETWEEN "2023-01-01" AND "2023-01-30"
),

interest_vendors AS (
SELECT DISTINCT
vendor_id,
country,
business_type
FROM vendor_table_1
LEFT JOIN vendor_category USING (vendor_id)
)
 
,events AS (
  SELECT DISTINCT 
  e.country,
  e.session_id,
  e.event_action,
  e.screen_type,
  e.vendorid,
  MAX(IF(array.name = "array_name_1", array.value, NULL)) AS array_name_1,
  MAX(IF(array.name = "array_name_2", array.value, NULL)) AS array_name_2
FROM events_table_1 AS e
LEFT JOIN UNNEST(e.array) AS array
WHERE e.partition_date BETWEEN "2023-01-01" AND "2023-01-30"
  AND e.event_action IN ("interested_event_1", "interested_event_2")
  AND ev.name IN ("array_name_1", "array_name_2")
GROUP BY 1,2,3,4,5
 )

 ,events_2 AS (
  SELECT
  events.*
 FROM events LEFT JOIN interest_vendors
 USING (country, vendor_id)
WHERE interest_vendors.business_type IN ("group_1", "group_2")
 )

,session_level AS (
SELECT DISTINCT
country,
session_id, 
IFNULL(MAX(IF(event_action = "interested_event_1" AND array_name_1 = "string", 1, 0)),0) AS fulfilled_criteria_1,
IFNULL(MAX(IF(event_action = "interested_event_2" AND array_name_2 = "abcd", 1, 0)),0) AS fulfilled_criteria_2,
IFNULL(MAX(IF(event_action = "interested_event_2" AND array_name_2 = "efgh", 1, 0)),0) AS fulfilled_criteria_3,
FROM events_2
GROUP BY 1
)

SELECT 
country,
COUNT(DISTINCT(IF((fulfilled_criteria_1 > 0), session_id, NULL))) AS sessions_with_only_criteria_1,
COUNT(DISTINCT(IF((fulfilled_criteria_1 > 0 AND fulfilled_criteria_2 > 0), session_id, NULL))) AS sessions_with_criteria_1_and_2,
COUNT(DISTINCT(IF((fulfilled_criteria_2 = 0 AND fulfilled_criteria_3 > 0), session_id, NULL))) AS sessions_with_criteria_3_but_not_2,
FROM session_funnel
LEFT JOIN session_level USING (session_id)
WHERE (stage_1 AND stage_2 AND stage_3 AND NOT stage_4 AND NOT final_stage)
GROUP BY 1
