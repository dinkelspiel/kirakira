import gleam/json
import wisp.{type Request, type Response}

pub fn logout(req: Request) -> Response {
  wisp.json_response(
    json.object([#("message", json.string("Logged out"))])
      |> json.to_string_builder,
    200,
  )
  |> wisp.set_cookie(
    req,
    "kk_session_token",
    "",
    wisp.PlainText,
    60 * 60 * 24 * 1000,
  )
}
