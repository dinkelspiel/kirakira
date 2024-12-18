SELECT
    "user".email, "user".username
FROM
    "user"
WHERE
    "user".email = $1
    OR "user".username = $2
