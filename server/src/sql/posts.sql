-- name: CreatePostWithBody :exec
INSERT INTO
    post (title, body, user_id, original_creator)
VALUES
    (?, ?, ?, ?);

-- name: CreatePostWithHref :exec
INSERT INTO
    post (title, href, user_id, original_creator)
VALUES
    (?, ?, ?, ?);

-- name: GetPostByID :one
SELECT
    post.id,
    post.title,
    post.href,
    post.body,
    user.username,
    post.original_creator,
    COUNT(DISTINCT user_like_post.id) AS like_count,
    COUNT(DISTINCT post_comment.id) AS comment_count,
    UNIX_TIMESTAMP (post.created_at) AS created_at
FROM
    post
    LEFT JOIN user_like_post ON post.id = user_like_post.post_id
    AND user_like_post.status = 'like'
    LEFT JOIN post_comment ON post.id = post_comment.post_id
    LEFT JOIN user ON post.user_id = user.id
WHERE
    post.id = ?
GROUP BY
    post.id,
    user.username
ORDER BY
    post.created_at DESC
LIMIT
    25;

-- name: GetPostByHref :one
SELECT
    post.title,
    post.href
FROM
    post
WHERE
    post.href = ?;

-- name: GetPosts :many
SELECT
    post.id,
    post.title,
    post.href,
    post.body,
    user.username,
    post.original_creator,
    COUNT(DISTINCT user_like_post.id) AS like_count,
    COUNT(DISTINCT post_comment.id) AS comment_count,
    UNIX_TIMESTAMP (post.created_at) AS created_at
FROM
    post
    LEFT JOIN user_like_post ON post.id = user_like_post.post_id
    AND user_like_post.status = 'like'
    LEFT JOIN post_comment ON post.id = post_comment.post_id
    LEFT JOIN user ON post.user_id = user.id
GROUP BY
    post.id,
    user.username
ORDER BY
    post.created_at DESC;

-- name: GetPostsUnlimited :many
SELECT
    post.id,
    post.title,
    post.href,
    post.body,
    user.username,
    post.original_creator,
    COUNT(DISTINCT user_like_post.id) AS like_count,
    COUNT(DISTINCT post_comment.id) AS comment_count,
    UNIX_TIMESTAMP (post.created_at) AS created_at
FROM
    post
    LEFT JOIN user_like_post ON post.id = user_like_post.post_id
    AND user_like_post.status = 'like'
    LEFT JOIN post_comment ON post.id = post_comment.post_id
    LEFT JOIN user ON post.user_id = user.id
GROUP BY
    post.id,
    user.username
ORDER BY
    post.created_at DESC
LIMIT
    25;

-- name: GetLatestPostByUserID :one
SELECT
    post.id,
    post.title,
    post.href,
    post.body,
    user.username,
    post.original_creator,
    COUNT(DISTINCT user_like_post.id) AS like_count,
    COUNT(DISTINCT post_comment.id) AS comment_count,
    UNIX_TIMESTAMP (post.created_at) AS created_at
FROM
    post
    LEFT JOIN user_like_post ON post.id = user_like_post.post_id
    AND user_like_post.status = 'like'
    LEFT JOIN post_comment ON post.id = post_comment.post_id
    LEFT JOIN user ON post.user_id = user.id
WHERE
    post.user_id = ?
GROUP BY
    post.id,
    user.username
ORDER BY
    post.created_at DESC
LIMIT
    1;
