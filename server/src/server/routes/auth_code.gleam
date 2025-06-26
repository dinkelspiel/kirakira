import gleam/bool
import gleam/http.{Get, Post}
import gleam/json
import gleam/result
import server/db/auth_code.{get_auth_code}
import server/db/user
import server/db/user_session
import server/generatetoken
import server/response
import wisp.{type Request, type Response}

pub fn auth_code(req: Request, token: String) -> Response {
  case req.method {
    Get -> show_auth_code(token)
    Post -> create_auth_code(req)
    _ -> wisp.method_not_allowed([Get, Post])
  }
}

fn show_auth_code(token: String) -> Response {
  let result = {
    use auth_code <- result.try(get_auth_code(token))
    use user <- result.try(user.get_user_by_id(auth_code.user_id))
    use <- bool.guard(
      when: auth_code.used,
      return: Error("Auth code is already used"),
    )

    Ok(
      json.object([#("username", json.string(user.username))])
      |> json.to_string_tree,
    )
  }

  response.generate_wisp_response(result)
}

fn create_auth_code(req: Request) -> Response {
  let result = {
    use auth_user_id <- result.try(user_session.get_user_id_from_session(req))

    let token = generatetoken.generate_token(64)

    use _ <- result.try(auth_code.create_auth_code(token, auth_user_id))

    Ok(
      json.object([#("message", json.string(token))])
      |> json.to_string_tree,
    )
  }

  response.generate_wisp_response(result)
}
