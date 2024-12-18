SELECT
    post_comment.body, post_comment.user_id
FROM
    post_comment
WHERE
    post_comment.post_id = $1
    AND post_comment.id = $2
