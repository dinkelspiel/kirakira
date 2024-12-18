SELECT
    "user".id,
    "user".username,
    "user".email,
    "user".password,
    "user".invited_by
FROM
    "user"
WHERE
    "user".username = $1