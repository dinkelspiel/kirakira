SELECT
    user_session.id,
    user_session.user_id
FROM
    user_session
WHERE
    user_session.token = $1