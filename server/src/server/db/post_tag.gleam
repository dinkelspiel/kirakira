import gleam/list
import gleam/result
import server/db
import server/sql

pub fn create_post_tag(post_id: Int, tag_id: Int) {
  case db.get_connection_raw() {
    Ok(db) ->
      case get_post_tag(post_id, tag_id) {
        Ok(_) -> {
          Nil
        }
        Error(_) -> {
          let _ = sql.create_post_tag(post_id, tag_id) |> db.exec(db, _)
          Nil
        }
      }
    Error(_) -> Nil
  }
}

pub fn get_post_tag(post_id: Int, tag_id: Int) {
  use db <- db.get_connection()

  use post_tag_rows <- result.try(
    sql.get_post_tags(post_id, tag_id)
    |> db.query(db, _)
    |> result.replace_error("Error getting post_tags from database"),
  )

  case
    post_tag_rows.rows
    |> list.first
  {
    Ok(_) -> Ok(Nil)
    Error(_) -> Error("No post_tag found")
  }
}
