-- Basic Joins (Medium Difficulty) Confirmation Rate
SELECT
s.user_id,
CASE WHEN c.user_id IS NULL
THEN 0.00
ELSE ROUND(SUM(c.action = 'confirmed')/COUNT(action),2)
END AS confirmation_rate
FROM Signups s
LEFT JOIN Confirmations c ON c.user_id = s.user_id
GROUP BY s.user_id

-- Basic Joins (Medium Difficulty) Managers with at least 5 Direct Reports
WITH manager AS (
    SELECT
    managerId,
    COUNT(DISTINCT(id)) AS direct_reports
    FROM Employee
    GROUP BY 1
)

SELECT
name
FROM Employee
LEFT JOIN manager on manager.managerId = Employee.id
WHERE manager.direct_reports > 4

-- 
