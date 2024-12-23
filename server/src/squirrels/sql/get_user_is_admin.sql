SELECT
    user_admin.id,
    user_admin.user_id
FROM
    user_admin
WHERE 
    user_admin.user_id = $1