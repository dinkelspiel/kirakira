import server/db/post
import server/db/user_like
import server/db/user_session
import server/response
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

    use _ <- result.try(post.get_post_by_id(req, post_id))

    user_like.toggle_like(user_id, post_id, user_like.Post)

    Ok(
      json.object([#("message", json.string("Toggled like for post"))])
      |> json.to_string_builder,
    )
  }

  response.generate_wisp_response(result)
}
