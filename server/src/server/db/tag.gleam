import gleam/json.{type Json}
import gleam/list
import gleam/result
import server/db
import shared.{type Tag, Tag, tag_category_to_string, tag_permission_to_string}
import squirrels/sql

pub type TagDbRow {
  TagDbRow(tag_id: Int, tag_name: String, tag_category: String)
}

pub fn get_tags() {
  use db_connection <- db.get_connection()

  use results <- result.try(
    sql.get_tags(db_connection)
    |> result.replace_error("Failed getting tags from db"),
  )

  Ok(
    list.map(results.rows, fn(row) {
      Tag(
        id: row.id,
        name: row.name,
        category: case row.category {
          sql.Format -> shared.Format
          sql.Genre -> shared.Genre
          sql.Kirakira -> shared.Kirakira
          sql.Platforms -> shared.Platforms
          sql.Practices -> shared.Practices
          sql.Tools -> shared.Tools
        },
        permission: case row.permission {
          sql.Admin -> shared.Admin
          sql.Member -> shared.Member
        },
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
  use db_connection <- db.get_connection()

  use tags <- result.try(
    sql.get_tags_by_id(db_connection, tag_id)
    |> result.replace_error("Problem getting tag by id from database"),
  )

  tags.rows
  |> list.first
  |> result.map(fn(row) {
    Tag(
      id: row.id,
      name: row.name,
      category: case row.category {
        sql.Format -> shared.Format
        sql.Genre -> shared.Genre
        sql.Kirakira -> shared.Kirakira
        sql.Platforms -> shared.Platforms
        sql.Practices -> shared.Practices
        sql.Tools -> shared.Tools
      },
      permission: case row.permission {
        sql.Admin -> shared.Admin
        sql.Member -> shared.Member
      },
    )
  })
  |> result.replace_error("No tag found when getting tag by id")
}
