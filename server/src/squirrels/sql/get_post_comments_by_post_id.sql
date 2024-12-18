SELECT
    post_comment.id,
    post_comment.body,
    "user".username,
    COUNT(DISTINCT user_like_post_comment.id) AS like_count,
    post_comment.parent_id,
    EXTRACT(
        EPOCH
        FROM
            post_comment.created_at
    ) AS created_at
FROM
    post_comment
    LEFT JOIN user_like_post_comment ON post_comment.id = user_like_post_comment.post_comment_id
    AND user_like_post_comment.status = 'like'
    LEFT JOIN "user" ON post_comment.user_id = "user".id
WHERE
    post_comment.post_id = $1
GROUP BY
    post_comment.id,
    "user".username
ORDER BY
    post_comment.created_at DESC
