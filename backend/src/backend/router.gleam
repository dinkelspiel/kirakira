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
import backend/scaffold.{page_scaffold}
import backend/web
import cors_builder as cors
import frontend
import frontend/state.{
  type Route, Active, CreatePost, Login, Model, NotFound, ShowPost, Signup,
  UserPage,
}
import gleam/http
import gleam/int
import gleam/option.{None}
import lustre/element
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

  // note assets under /static are caught by web.middleware before this
  case wisp.path_segments(req) {
    ["api", ..] -> api_routes(req, wisp.path_segments(req))
    _ -> page_routes(wisp.path_segments(req))
  }
}

fn page_routes(route_segments: List(String)) -> Response {
  let route: Route = case route_segments {
    [] -> Active
    ["auth", "login"] -> Login
    ["auth", "signup", auth_code] -> Signup(auth_code: auth_code)
    ["create-post"] -> CreatePost
    ["user", username] -> UserPage(username)
    ["post", post_id] ->
      case int.parse(post_id) {
        Ok(id) -> ShowPost(id)
        Error(_) -> NotFound
      }
    _ -> NotFound
  }

  let model =
    Model(
      route,
      inviter: "",
      auth_user: None,
      sign_up_username: "",
      sign_up_email: "",
      sign_up_password: "",
      sign_up_error: None,
      login_email_username: "",
      login_password: "",
      login_error: None,
      create_post_title: "",
      create_post_href: "",
      create_post_body: "",
      create_post_original_creator: False,
      create_post_tags: [],
      create_post_use_body: False,
      create_post_error: None,
      posts: [],
      show_post: None,
      create_comment_body: "",
      create_comment_parent_id: None,
      create_comment_error: None,
      tags: [],
      invite_link: None,
    )

  let content = frontend.view(model) |> page_scaffold()

  wisp.response(200)
  |> wisp.set_header("Content-Type", "text/html")
  |> wisp.html_body(content |> element.to_document_string_builder())
}

fn api_routes(req: Request, route_segments: List(String)) -> Response {
  case route_segments {
    ["api", "posts"] -> posts.posts(req)
    ["api", "posts", post_id] ->
      case int.parse(post_id) {
        Ok(id) -> post.post(req, id)
        Error(_) -> response.error("Invalid post_id for post, must be int")
      }
    ["api", "posts", post_id, "likes"] ->
      case int.parse(post_id) {
        Ok(post_id) -> post_likes.post_likes(req, post_id)
        Error(_) -> response.error("Invalid post_id for post, must be int")
      }
    ["api", "posts", post_id, "comments"] ->
      case int.parse(post_id) {
        Ok(id) -> comment.comment(req, id)
        Error(_) -> response.error("Invalid post_id for post, must be int")
      }
    ["api", "posts", "comments", post_comment_id, "likes"] ->
      case int.parse(post_comment_id) {
        Ok(post_comment_id) ->
          post_comment_likes.post_comment_likes(req, post_comment_id)
        Error(_) ->
          response.error("Invalid post_comment_id for comment, must be int")
      }
    ["api", "users"] -> users.users(req)
    ["api", "tags"] -> tags.tags(req)
    ["api", "auth-code"] -> auth_code.auth_code(req, "")
    ["api", "auth-code", token] -> auth_code.auth_code(req, token)
    ["api", "auth", "validate"] -> validate.validate(req)
    ["api", "auth", "login"] -> login.login(req)
    ["api", "auth", "logout"] -> logout.logout(req)
    _ -> wisp.not_found()
  }
}
