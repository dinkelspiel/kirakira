import backend/db
import backend/db/auth_code.{type AuthCode, get_auth_code}
import backend/db/user.{get_user_by_id}
import backend/db/user_session
import backend/generatetoken.{generate_token}
import backend/response
import beecrypt
import cake
import cake/dialect/mysql_dialect
import cake/insert as i
import cake/join as j
import cake/param
import cake/select as s
import cake/update as u
import cake/where as w
import gleam/bool
import gleam/dynamic
import gleam/http.{Get, Post}
import gleam/io
import gleam/json
import gleam/list
import gleam/result
import gleam/string
import gleam/string_builder
import gmysql
import wisp.{type Request, type Response}

pub fn validate(req: Request) -> Response {
  // This handler for `/comments` can respond to both GET and POST requests,
  // so we pattern match on the method here.
  case req.method {
    Get -> validate_session(req)
    // Post -> create_comment(req)
    _ -> wisp.method_not_allowed([Get])
  }
}

fn validate_session(req: Request) -> Response {
  let result = {
    use user_id <- result.try(user_session.get_user_id_from_session(req))

    use user <- result.try(user.get_user_by_id(user_id))

    let is_admin = user.is_user_admin(user.id)

    Ok(
      json.object([
        #("username", json.string(user.username)),
        #("user_id", json.int(user_id)),
        #("is_admin", json.bool(is_admin)),
      ])
      |> json.to_string_builder,
    )
  }

  response.generate_wisp_response(result)
}
