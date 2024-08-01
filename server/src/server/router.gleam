import client
import client/state.{
  type Route, Active, CreatePost, Login, Model, NotFound, ShowPost, Signup,
  UserPage,
}
import cors_builder as cors
import gleam/http
import gleam/int
import gleam/option.{None, Some}
import lustre/element
import server/db/user
import server/db/user_session
import server/response
import server/routes/auth/login
import server/routes/auth/logout
import server/routes/auth/validate
import server/routes/auth_code
import server/routes/comment
import server/routes/comments/likes as post_comment_likes
import server/routes/post
import server/routes/posts
import server/routes/posts/likes as post_likes
import server/routes/robots.{robots_txt}
import server/routes/sitemap.{sitemap_xml}
import server/routes/tags
import server/routes/users
import server/scaffold.{page_scaffold}
import server/web
import wisp.{type Request, type Response}

pub fn handle_request(req: Request) -> Response {
  use req <- web.middleware(req)
  use req <- cors.wisp_middleware(
    req,
    cors.new()
      |> cors.allow_origin("http://localhost:1234")
      |> cors.allow_method(http.Get)
      |> cors.allow_method(http.Post)
      |> cors.allow_header("Content-Type"),
  )

  // note assets under /static are caught by web.middleware before this
  case wisp.path_segments(req) {
    ["api", ..] -> api_routes(req, wisp.path_segments(req))
    ["robots.txt"] -> robots_txt()
    ["sitemap.xml"] -> sitemap_xml(req)
    _ -> page_routes(req, wisp.path_segments(req))
  }
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

fn page_routes(req: Request, route_segments: List(String)) -> Response {
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
      auth_user: case user_session.get_user_id_from_session(req) {
        Ok(user_id) ->
          case user.get_user_by_id(user_id) {
            Ok(user) ->
              Some(state.AuthUser(
                is_admin: user.is_user_admin(user.id),
                user_id: user_id,
                username: user.username,
              ))
            Error(_) -> None
          }
        Error(_) -> None
      },
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
      posts: {
        case posts.list_posts(req) {
          Ok(posts) -> posts
          Error(_) -> []
        }
      },
      show_post: {
        case route {
          ShowPost(id) ->
            case post.show_post(req, id) {
              Ok(post) -> Some(post)
              Error(_) -> None
            }
          _ -> None
        }
      },
      create_comment_body: "",
      create_comment_parent_id: None,
      create_comment_error: None,
      tags: case tags.list_tags() {
        Ok(tags) -> tags
        Error(_) -> []
      },
      invite_link: None,
    )

  wisp.response(200)
  |> wisp.set_header("Content-Type", "text/html")
  |> wisp.html_body(
    client.view(model)
    |> page_scaffold()
    |> element.to_document_string_builder(),
  )
}
