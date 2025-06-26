-- name: CreateUserLikePost :exec
INSERT INTO
    user_like_post (user_id, post_id, status)
VALUES
    (?, ?, ?);

-- name: CreateUserLikePostComment :exec
INSERT INTO
    user_like_post (user_id, post_id, status)
VALUES
    (?, ?, ?);

-- name: GetUserPostLikes :one
SELECT
    user_like_post.id,
    user_like_post.user_id,
    user_like_post.post_id,
    user_like_post.status
FROM
    user_like_post
WHERE
    user_like_post.user_id = ?
    AND user_like_post.post_id = ?;

-- name: GetUserPostCommentLikes :one
SELECT
    user_like_post_comment.id,
    user_like_post_comment.user_id,
    user_like_post_comment.post_comment_id,
    user_like_post_comment.status
FROM
    user_like_post_comment
WHERE
    user_like_post_comment.user_id = ?
    AND user_like_post_comment.post_comment_id = ?;

-- name: UpdateUserLikePostStatus :exec
UPDATE user_like_post
SET
    status = ?
WHERE
    id = ?;

-- name: UpdateUserLikePostCommentStatus :exec
UPDATE user_like_post_comment
SET
    status = ?
WHERE
    id = ?;
