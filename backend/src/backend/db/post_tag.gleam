import backend/db
import backend/db/post
import backend/db/tag
import backend/db/user
import backend/db/user_session
import backend/response
import backend/web
import cake
import cake/dialect/mysql_dialect
import cake/fragment as f
import cake/insert as i
import cake/join as j
import cake/param
import cake/select as s
import cake/where as w
import decode
import gleam/bit_array
import gleam/bool
import gleam/dynamic.{type Dynamic}
import gleam/http.{Get, Post}
import gleam/int
import gleam/io
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string_builder
import gmysql
import shared.{Admin, Member}
import wisp.{type Request, type Response}

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
