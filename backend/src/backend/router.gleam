import backend/response
import backend/routes/auth/login
import backend/routes/auth/logout
import backend/routes/auth/validate
import backend/routes/auth_code
import backend/routes/comment
import backend/routes/comments/likes as post_comment_likes
import backend/routes/post
import backend/routes/posts
import backend/routes/posts/likes as post_likes
import backend/routes/tags
import backend/routes/users
import backend/web
import cors_builder as cors
import gleam/http
import gleam/int
import wisp.{type Request, type Response}

fn cors() {
  cors.new()
  |> cors.allow_origin("http://localhost:1234")
  |> cors.allow_method(http.Get)
  |> cors.allow_method(http.Post)
  |> cors.allow_header("content-type")
}

pub fn handle_request(req: Request) -> Response {
  use req <- web.middleware(req)
  use req <- cors.wisp_middleware(req, cors())

  case wisp.path_segments(req) {
    ["posts"] -> posts.posts(req)
    ["posts", post_id] ->
      case int.parse(post_id) {
        Ok(id) -> post.post(req, id)
        Error(_) -> response.error("Invalid post_id for post, must be int")
      }
    ["posts", post_id, "likes"] ->
      case int.parse(post_id) {
        Ok(post_id) -> post_likes.post_likes(req, post_id)
        Error(_) -> response.error("Invalid post_id for post, must be int")
      }
    ["posts", post_id, "comments"] ->
      case int.parse(post_id) {
        Ok(id) -> comment.comment(req, id)
        Error(_) -> response.error("Invalid post_id for post, must be int")
      }
    ["posts", "comments", post_comment_id, "likes"] ->
      case int.parse(post_comment_id) {
        Ok(post_comment_id) ->
          post_comment_likes.post_comment_likes(req, post_comment_id)
        Error(_) ->
          response.error("Invalid post_comment_id for comment, must be int")
      }
    ["users"] -> users.users(req)
    ["tags"] -> tags.tags(req)
    ["auth-code"] -> auth_code.auth_code(req, "")
    ["auth-code", token] -> auth_code.auth_code(req, token)
    ["auth", "validate"] -> validate.validate(req)
    ["auth", "login"] -> login.login(req)
    ["auth", "logout"] -> logout.logout(req)
    _ -> wisp.not_found()
  }
}
