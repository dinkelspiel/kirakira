SELECT
    auth_code.id,
    auth_code.token,
    auth_code.creator_id,
    auth_code.used
FROM
    auth_code
WHERE
    auth_code.token = $1