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
