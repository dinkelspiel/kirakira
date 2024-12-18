SELECT
    tag.id, tag.name
FROM
    post_tag
    LEFT JOIN tag
    ON tag.id = post_tag.tag_id
WHERE
    post_tag.post_id = $1
