SELECT
    post.title, post.href
FROM
    post
WHERE post.href = $1
