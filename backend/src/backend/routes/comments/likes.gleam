import backend/db/post_comment
import backend/db/user_like
import backend/db/user_session
import backend/response
import gleam/http.{Post}
import gleam/json
import gleam/result
import wisp.{type Request, type Response}

pub fn post_comment_likes(req: Request, post_comment_id: Int) -> Response {
  case req.method {
    Post -> like_post_comment(req, post_comment_id)
    _ -> wisp.method_not_allowed([Post])
  }
}

pub fn like_post_comment(req: Request, post_comment_id: Int) -> Response {
  let result = {
    use user_id <- result.try(user_session.get_user_id_from_session(req))

    use post_comment <- result.try(post_comment.get_post_comment_by_id(
      req,
      post_comment_id,
    ))

    let _ =
      user_like.toggle_like(user_id, post_comment.id, user_like.PostComment)

    Ok(
      json.object([#("message", json.string("Toggled like for post comment"))])
      |> json.to_string_builder,
    )
  }

  response.generate_wisp_response(result)
}
