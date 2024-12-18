UPDATE
    user_forgot_password
SET
    used = TRUE
WHERE
    token = $1