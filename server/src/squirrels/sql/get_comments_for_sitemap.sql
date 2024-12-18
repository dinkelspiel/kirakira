SELECT
    post_comment.id,
    EXTRACT(EPOCH FROM post_comment.created_at) AS created_at
FROM
    post_comment
WHERE
    post_comment.post_id = $1
ORDER BY post_comment.created_at DESC
