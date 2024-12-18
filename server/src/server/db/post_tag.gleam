import gleam/list
import gleam/result
import server/db
import squirrels/sql

pub fn create_post_tag(post_id: Int, tag_id: Int) {
  case get_post_tag(post_id, tag_id) {
    Ok(_) -> {
      Nil
    }
    Error(_) -> {
      let _ = sql.create_post_tag(db.get_connection(), post_id, tag_id)
      Nil
    }
  }
}

pub fn get_post_tag(post_id: Int, tag_id: Int) {
  use post_tag_rows <- result.try(
    sql.get_post_tags(db.get_connection(), post_id, tag_id)
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
