import gleam/http.{Get}
import gleam/json
import gleam/result
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
  use post <- result.try(
    post.get_post_by_id(req, post_id)
    |> result.replace_error("Problem getting post from database"),
  )

  Ok(post)
}

fn show_post_res(req: Request, post_id: Int) -> Response {
  let result = show_post(req, post_id)

  response.generate_wisp_response(case result {
    Ok(post) -> Ok(post |> post.post_to_json |> json.to_string_tree)
    Error(_) -> Error("Problem getting post from database")
  })
}
