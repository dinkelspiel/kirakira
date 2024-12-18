UPDATE
    auth_code
SET
    used = TRUE
WHERE
    id = $1
