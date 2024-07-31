import cake/insert as i
import cake/select as s
import cake/where as w
import gleam/dynamic
import gleam/list
import gleam/result
import gmysql
import server/db

pub fn create_post_tag(post_id: Int, tag_id: Int) {
  case get_post_tag(post_id, tag_id) {
    Ok(_) -> {
      Nil
    }
    Error(_) -> {
      let _ =
        [i.row([i.int(post_id), i.int(tag_id)])]
        |> i.from_values(table_name: "post_tag", columns: ["post_id", "tag_id"])
        |> i.to_query
        |> db.execute_write([gmysql.to_param(post_id), gmysql.to_param(tag_id)])
      Nil
    }
  }
}

pub fn get_post_tag(post_id: Int, tag_id: Int) {
  use post_tag_rows <- result.try(
    s.new()
    |> s.selects([s.col("post_tag.post_id"), s.col("post_tag.tag_id")])
    |> s.from_table("post_tag")
    |> s.where(
      w.and([
        w.eq(w.col("post_tag.post_id"), w.int(post_id)),
        w.eq(w.col("post_tag.tag_id"), w.int(tag_id)),
      ]),
    )
    |> s.to_query()
    |> db.execute_read(
      [gmysql.to_param(post_id), gmysql.to_param(tag_id)],
      dynamic.tuple2(dynamic.int, dynamic.int),
    )
    |> result.replace_error("Error getting post_tags from database"),
  )

  case
    post_tag_rows
    |> list.first
  {
    Ok(_) -> Ok(Nil)
    Error(_) -> Error("No post_tag found")
  }
}
