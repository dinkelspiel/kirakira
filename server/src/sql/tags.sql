-- name: CreatePostTag :exec
INSERT INTO
    post_tag (post_id, tag_id)
VALUES
    (?, ?);

-- name: GetPostTags :one
SELECT
    post_tag.post_id,
    post_tag.tag_id
FROM
    post_tag
WHERE
    post_tag.post_id = ?
    AND post_tag.tag_id = ?;

-- name: GetTagsByPostID :many
SELECT
    tag.id,
    tag.name
FROM
    post_tag
    LEFT JOIN tag ON tag.id = post_tag.tag_id
WHERE
    post_tag.post_id = ?;

-- name: GetTagsByID :one
SELECT
    tag.id,
    tag.name,
    tag.category,
    tag.permission
FROM
    tag
WHERE
    tag.id = ?;

-- name: GetTags :many
SELECT
    tag.id,
    tag.name,
    tag.category,
    tag.permission
FROM
    tag;
