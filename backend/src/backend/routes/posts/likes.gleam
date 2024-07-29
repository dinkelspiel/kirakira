import backend/db/user_like
import backend/db/user_session
import backend/response
import gleam/http.{Post}
import gleam/json
import gleam/result
import wisp.{type Request, type Response}

pub fn post_likes(req: Request, post_id: Int) -> Response {
  case req.method {
    Post -> like_post(req, post_id)
    _ -> wisp.method_not_allowed([Post])
  }
}

pub fn like_post(req: Request, post_id: Int) -> Response {
  let result = {
    use user_id <- result.try(user_session.get_user_id_from_session(req))

    user_like.toggle_like(user_id, post_id, user_like.Post)

    Ok(
      json.object([#("message", json.string("Toggled like for post"))])
      |> json.to_string_builder,
    )
  }

  response.generate_wisp_response(result)
}
