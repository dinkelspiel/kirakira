-- name: CreateAuthCode :exec
INSERT INTO
    auth_code (token, creator_id)
VALUES
    (?, ?);

-- name: GetAuthCodeByToken :one
SELECT
    auth_code.id,
    auth_code.token,
    auth_code.creator_id,
    auth_code.used
FROM
    auth_code
WHERE
    auth_code.token = ?;

-- name: UpdateAuthCodeAsUsed :exec
UPDATE auth_code
SET
    used = TRUE
WHERE
    id = ?;
