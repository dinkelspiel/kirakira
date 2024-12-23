SELECT
    user_forgot_password.id,
    user_forgot_password.user_id
FROM
    user_forgot_password
WHERE
    user_forgot_password.token = $1
    AND user_forgot_password.used = FALSE