import gleam/dynamic
import gleam/dynamic/decode
import gleam/http.{Post}
import gleam/json
import gleam/result
import server/db/forgot_password
import server/db/user
import server/response
import wisp.{type Request, type Response}

pub fn change_password(req: Request, token: String) -> Response {
  case req.method {
    Post -> do_change_password(req, token)
    _ -> wisp.method_not_allowed([Post])
  }
}

type ChangePassword {
  ChangePassword(password: String)
}

fn decode_change_password(
  json: dynamic.Dynamic,
) -> Result(ChangePassword, List(decode.DecodeError)) {
  let decoder = {
    use password <- decode.field("password", decode.string)

    decode.success(ChangePassword(password:))
  }
  decode.run(json, decoder)
}

fn do_change_password(req: Request, token: String) {
  use body <- wisp.require_json(req)

  let result = {
    use request <- result.try(case decode_change_password(body) {
      Ok(val) -> Ok(val)
      Error(_) -> Error("Invalid body recieved")
    })

    use user <- result.try(forgot_password.get_user_by_forgot_password(token))

    use _ <- result.try(user.set_password_for_user(user.id, request.password))
    use _ <- result.try(forgot_password.mark_forgot_password_as_used(token))

    Ok(
      json.object([#("message", json.string("Updated password"))])
      |> json.to_string_tree,
    )
  }

  response.generate_wisp_response(result)
}
