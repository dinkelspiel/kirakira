SELECT
    post.id,
    post.title,
    post.href,
    post.body,
    "user".username,
    post.original_creator,
    COUNT(DISTINCT user_like_post.id) AS like_count,
    COUNT(DISTINCT post_comment.id) AS comment_count,
    EXTRACT(
        EPOCH
        FROM
            post.created_at
    ) AS created_at
FROM
    post
    LEFT JOIN user_like_post ON post.id = user_like_post.post_id
    AND user_like_post.status = 'like'
    LEFT JOIN post_comment ON post.id = post_comment.post_id
    LEFT JOIN "user" ON post.user_id = "user".id
GROUP BY
    post.id,
    "user".username
ORDER BY
    post.created_at DESC
LIMIT
    25
