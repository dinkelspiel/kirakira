SELECT
    tag.id, tag.name, tag.category, tag.permission
FROM
    tag
WHERE
    tag.id = $1
