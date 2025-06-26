-- name: CreatePostComment :exec
INSERT INTO
    post_comment (body, user_id, post_id, parent_id)
VALUES
    (?, ?, ?, ?);

-- name: CreatePostCommentNoParent :exec
INSERT INTO
    post_comment (body, user_id, post_id, parent_id)
VALUES
    (?, ?, ?, NULL);

-- name: GetPostCommentsByPostID :many
SELECT
    post_comment.id,
    post_comment.body,
    user.username,
    COUNT(DISTINCT user_like_post_comment.id) AS like_count,
    post_comment.parent_id,
    UNIX_TIMESTAMP (post_comment.created_at) AS created_at
FROM
    post_comment
    LEFT JOIN user_like_post_comment ON post_comment.id = user_like_post_comment.post_comment_id
    AND user_like_post_comment.status = 'like'
    LEFT JOIN user ON post_comment.user_id = user.id
WHERE
    post_comment.post_id = ?
GROUP BY
    post_comment.id,
    user.username
ORDER BY
    post_comment.created_at DESC;

-- name: GetPostCommentsByID :one
SELECT
    post_comment.id,
    post_comment.body,
    user.username,
    COUNT(DISTINCT user_like_post_comment.id) AS like_count,
    post_comment.parent_id,
    UNIX_TIMESTAMP (post_comment.created_at) AS created_at
FROM
    post_comment
    LEFT JOIN user_like_post_comment ON post_comment.id = user_like_post_comment.post_comment_id
    AND user_like_post_comment.status = 'like'
    LEFT JOIN user ON post_comment.user_id = user.id
WHERE
    post_comment.id = ?
GROUP BY
    post_comment.id,
    user.username
ORDER BY
    post_comment.created_at DESC;

-- name: GetPostCommentParentInPost :one
SELECT
    post_comment.body,
    post_comment.user_id
FROM
    post_comment
WHERE
    post_comment.post_id = ?
    AND post_comment.id = ?;

-- name: GetCommentsForSitemap :many
SELECT
    post_comment.id,
    UNIX_TIMESTAMP (post_comment.created_at) AS created_at
FROM
    post_comment
WHERE
    post_comment.post_id = ?
ORDER BY
    post_comment.created_at DESC;
