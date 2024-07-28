import backend/db
import backend/db/auth_code.{type AuthCode, get_auth_code}
import backend/db/user.{get_user_by_email, get_user_by_username}
import backend/db/user_session.{create_user_session}
import backend/generatetoken.{generate_token}
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
import gleam/regex
import gleam/result
import gleam/string
import gleam/string_builder
import gmysql
import wisp.{type Request, type Response}

pub fn login(req: Request) -> Response {
  use body <- wisp.require_json(req)

  case req.method {
    Post -> do_login(req, body)
    _ -> wisp.method_not_allowed([Post])
  }
}

type Login {
  Login(email_username: String, password: String)
}

fn decode_create_user(
  json: dynamic.Dynamic,
) -> Result(Login, dynamic.DecodeErrors) {
  let decoder =
    dynamic.decode2(
      Login,
      dynamic.field("email_username", dynamic.string),
      dynamic.field("password", dynamic.string),
    )
  case decoder(json) {
    Ok(login) ->
      Ok(Login(
        email_username: string.lowercase(login.email_username),
        password: login.password,
      ))
    Error(error) -> Error(error)
  }
}

fn do_login(req: Request, body: dynamic.Dynamic) {
  let result = {
    use request_user <- result.try(case decode_create_user(body) {
      Ok(val) -> Ok(val)
      Error(_) -> Error("Invalid body recieved")
    })

    use user <- result.try({
      case get_user_by_username(request_user.email_username) {
        Ok(user) -> Ok(user)
        Error(_) ->
          case get_user_by_email(request_user.email_username) {
            Ok(user) -> Ok(user)
            Error(_) -> Error("No user found with email or username")
          }
      }
    })

    use <- bool.guard(
      when: !beecrypt.verify(request_user.password, user.password),
      return: Error("Passwords do not match"),
    )

    use session_token <- result.try(create_user_session(user.id))

    Ok(session_token)
  }

  case result {
    Ok(session_token) ->
      wisp.json_response(
        json.object([#("message", json.string("Logged in"))])
          |> json.to_string_builder,
        201,
      )
      |> wisp.set_cookie(
        req,
        "kk_session_token",
        session_token,
        wisp.PlainText,
        60 * 60 * 24 * 1000,
      )
    Error(error) ->
      wisp.json_response(
        json.object([#("error", json.string(error))])
          |> json.to_string_builder,
        200,
      )
  }
}
