import backend/db
import backend/db/post
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
import wisp.{type Request, type Response}

pub fn post(req: Request, post_id: Int) -> Response {
  case req.method {
    Get -> show_post(req, post_id)
    _ -> wisp.method_not_allowed([Get])
  }
}

fn show_post(req: Request, post_id: Int) {
  let result = {
    use post_rows <- result.try(
      post.get_posts_query()
      |> s.where(w.eq(w.col("post.id"), w.int(post_id)))
      |> post.run_post_query([gmysql.to_param(post_id)])
      |> result.replace_error("Problem getting post from database"),
    )

    use post <- result.try(
      post.post_rows_to_post(req, post_rows, True)
      |> list.first
      |> result.replace_error("No post found"),
    )

    Ok(post |> post.post_to_json |> json.to_string_builder)
  }

  response.generate_wisp_response(result)
}
