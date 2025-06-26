import gleam/json.{type Json}
import gleam/list
import gleam/result
import server/db
import server/sql
import shared.{type Tag, Tag, tag_category_to_string, tag_permission_to_string}

pub type TagDbRow {
  TagDbRow(tag_id: Int, tag_name: String, tag_category: String)
}

pub fn get_tags() {
  use db <- db.get_connection()

  use results <- result.try(
    sql.get_tags()
    |> db.query(db, _)
    |> result.replace_error("Failed getting tags from db"),
  )

  Ok(
    list.map(results.rows, fn(row) {
      Tag(
        id: row.id,
        name: row.name,
        category: shared.decode_tag_category(row.category),
        permission: shared.decode_tag_permission(row.permission),
      )
    }),
  )
}

pub fn tag_to_json(tag: Tag) -> Json {
  json.object([
    #("id", json.int(tag.id)),
    #("name", json.string(tag.name)),
    #("category", json.string(tag_category_to_string(tag.category))),
    #("permission", json.string(tag_permission_to_string(tag.permission))),
  ])
}

pub fn get_tag_by_id(tag_id: Int) -> Result(Tag, String) {
  use db <- db.get_connection()

  use tags <- result.try(
    sql.get_tags_by_id(tag_id)
    |> db.query(db, _)
    |> result.replace_error("Problem getting tag by id from database"),
  )

  tags.rows
  |> list.first
  |> result.map(fn(row) {
    Tag(
      id: row.id,
      name: row.name,
      category: shared.decode_tag_category(row.category),
      permission: shared.decode_tag_permission(row.permission),
    )
  })
  |> result.replace_error("No tag found when getting tag by id")
}
