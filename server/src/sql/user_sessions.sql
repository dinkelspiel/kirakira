-- name: CreateUserSession :exec
INSERT INTO
    user_session (user_id, token)
VALUES
    (?, ?);

-- name: GetUserIdFromSession :one
SELECT
    user_session.id,
    user_session.user_id
FROM
    user_session
WHERE
    user_session.token = ?;
