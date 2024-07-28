import backend/db
import backend/db/post
import backend/db/user_like
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

pub fn post_likes(req: Request, post_id: Int) -> Response {
  case req.method {
    Post -> like_post(req, post_id)
    _ -> wisp.method_not_allowed([Post])
  }
}

pub fn like_post(req: Request, post_id: Int) -> Response {
  let result = {
    use user_id <- result.try(user_session.get_user_id_from_session(req))

    use post <- result.try(post.get_post_by_id(req, post_id))

    user_like.toggle_like(user_id, post_id, user_like.Post)

    Ok(
      json.object([#("message", json.string("Toggled like for post"))])
      |> json.to_string_builder,
    )
  }

  response.generate_wisp_response(result)
}
