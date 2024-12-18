SELECT
    user_like_post_comment.id,
    user_like_post_comment.user_id,
    user_like_post_comment.post_comment_id,
    user_like_post_comment.status
FROM
    user_like_post_comment
WHERE
    user_like_post_comment.user_id = $1
    AND user_like_post_comment.post_comment_id = $2