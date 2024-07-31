import cake/select as s
import cake/where as w
import gleam/http.{Get}
import gleam/json
import gleam/list
import gleam/result
import gmysql
import server/db/post
import server/response
import shared
import wisp.{type Request, type Response}

pub fn post(req: Request, post_id: Int) -> Response {
  case req.method {
    Get -> show_post_res(req, post_id)
    _ -> wisp.method_not_allowed([Get])
  }
}

pub fn show_post(req: Request, post_id: Int) -> Result(shared.Post, String) {
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

  Ok(post)
}

fn show_post_res(req: Request, post_id: Int) -> Response {
  let result = show_post(req, post_id)

  response.generate_wisp_response(case result {
    Ok(post) -> Ok(post |> post.post_to_json |> json.to_string_builder)
    Error(_) -> Error("Problem getting post from database")
  })
}
