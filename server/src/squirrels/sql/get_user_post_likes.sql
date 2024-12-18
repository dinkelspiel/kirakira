SELECT
    user_like_post.id,
    user_like_post.user_id,
    user_like_post.post_id,
    user_like_post.status
FROM
    user_like_post
WHERE
    user_like_post.user_id = $1
    AND user_like_post.post_id = $2