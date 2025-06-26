import beecrypt
import gleam/bool
import gleam/dynamic
import gleam/dynamic/decode
import gleam/http.{Post}
import gleam/json
import gleam/result
import gleam/string
import server/db/user.{get_user_by_email, get_user_by_username}
import server/db/user_session.{create_user_session}
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
) -> Result(Login, List(decode.DecodeError)) {
  let decoder = {
    use email_username <- decode.field("email_username", decode.string)
    use password <- decode.field("password", decode.string)

    decode.success(Login(email_username:, password:))
  }

  case decode.run(json, decoder) {
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
          |> json.to_string_tree,
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
          |> json.to_string_tree,
        200,
      )
  }
}
