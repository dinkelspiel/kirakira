import gleam/dynamic
import gleam/http.{Get, Post}
import gleam/httpc
import gleam/json
import gleam/result
import gleesend
import gleesend/emails
import server/db/forgot_password
import server/env.{get_env}
import server/response
import wisp.{type Request, type Response}

pub fn forgot_password(req: Request, token: String) -> Response {
  case req.method {
    Post -> create_forgot_password(req)
    Get -> get_forgot_password(req, token)
    _ -> wisp.method_not_allowed([Get, Post])
  }
}

type CreateForgotPassword {
  CreateForgotPassword(email: String)
}

fn decode_create_forgot_password(
  json: dynamic.Dynamic,
) -> Result(CreateForgotPassword, dynamic.DecodeErrors) {
  let decoder =
    dynamic.decode1(
      CreateForgotPassword,
      dynamic.field("email", dynamic.string),
    )
  decoder(json)
}

fn create_forgot_password(req: Request) {
  use body <- wisp.require_json(req)

  let result = {
    use request <- result.try(case decode_create_forgot_password(body) {
      Ok(val) -> Ok(val)
      Error(_) -> Error("Invalid body recieved")
    })

    use token <- result.try(forgot_password.create_forgot_password(
      request.email,
    ))

    let env = get_env()

    let resend_client = gleesend.Resend(api_key: env.resend_api_key)

    let email =
      emails.create_email(
        client: resend_client,
        from: "Kirakira <" <> env.resend_email <> ">",
        to: [request.email],
        subject: "Kirakira change password request",
      )
      |> emails.with_text(
        "Change your password by following this link https://kirakira.keii.dev/auth/forgot-password/"
        <> token,
      )
      |> emails.to_request

    use _ <- result.try(case httpc.send(email) {
      Ok(_) -> Ok(Nil)
      Error(_) ->
        Error("Problem sending email to user, contact an administrator")
    })

    Ok(
      json.object([#("message", json.string("Sent email"))])
      |> json.to_string_tree,
    )
  }

  response.generate_wisp_response(result)
}

fn get_forgot_password(_: Request, token: String) {
  let result = {
    use user <- result.try(forgot_password.get_user_by_forgot_password(token))

    Ok(
      json.object([#("username", json.string(user.username))])
      |> json.to_string_tree,
    )
  }

  response.generate_wisp_response(result)
}
