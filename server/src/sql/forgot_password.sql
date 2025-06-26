-- name: CreateForgotPassword :exec
INSERT INTO
    user_forgot_password (user_id, token)
VALUES
    (?, ?);

-- name: GetUserByForgotPassword :one
SELECT
    user_forgot_password.id,
    user_forgot_password.user_id
FROM
    user_forgot_password
WHERE
    user_forgot_password.token = ?
    AND user_forgot_password.used = FALSE;

-- name: UpdateForgotPasswordAsUsed :exec
UPDATE user_forgot_password
SET
    used = TRUE
WHERE
    token = ?;
