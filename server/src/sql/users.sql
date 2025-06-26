-- name: CreateUser :exec
INSERT INTO
    user (username, email, password, invited_by)
VALUES
    (?, ?, ?, ?);

-- name: GetUserByEmailOrUsername :one
SELECT
    user.email,
    user.username
FROM
    user
WHERE
    user.email = ?
    OR user.username = ?;

-- name: GetUserByEmail :one
SELECT
    user.id,
    user.username,
    user.email,
    user.password,
    user.invited_by
FROM
    user
WHERE
    user.email = ?;

-- name: GetUserByID :one
SELECT
    user.id,
    user.username,
    user.email,
    user.password,
    user.invited_by
FROM
    user
WHERE
    user.id = ?;

-- name: GetUserByUsername :one
SELECT
    user.id,
    user.username,
    user.email,
    user.password,
    user.invited_by
FROM
    user
WHERE
    user.username = ?;

-- name: UpdateUserPassword :exec
UPDATE user
SET
    password = ?
WHERE
    user.id = ?;
