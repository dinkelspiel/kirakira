SELECT
    post_tag.post_id, post_tag.tag_id
FROM
    post_tag
WHERE
    post_tag.post_id = $1
    AND post_tag.tag_id = $2
