UPDATE
    "user"
SET
    password = $2
WHERE
    "user".id = $1