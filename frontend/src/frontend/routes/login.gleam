import env
import frontend/components/button.{button_class}
import frontend/components/input.{input_class}
import frontend/state.{
  type Model, LoginResponded, LoginUpdateEmailUsername, LoginUpdatePassword,
  RequestLogin, message_error_decoder,
}
import gleam/json
import gleam/option.{None, Some}
import lustre/attribute.{class}
import lustre/element.{text}
import lustre/element/html.{button, div, h1, input}
import lustre/event
import lustre_http

pub fn login(model: Model) {
  lustre_http.post(
    env.get_api_url() <> "/api/auth/login",
    json.object([
      #("email_username", json.string(model.login_email_username)),
      #("password", json.string(model.login_password)),
    ]),
    lustre_http.expect_json(message_error_decoder(), LoginResponded),
  )
}

pub fn login_view(model: Model) {
  div([class("flex flex-col  mx-auto max-w-[450px] w-full gap-4")], [
    h1([class("text-[#584355] font-bold")], [text("Login")]),
    div([class("grid lg:grid-cols-[170px,1fr] gap-2 w-full")], [
      div([], [text("E-mail or Username")]),
      input([input_class(), event.on_input(LoginUpdateEmailUsername)]),
      div([], [text("Password")]),
      input([
        input_class(),
        event.on_input(LoginUpdatePassword),
        attribute.attribute("type", "password"),
      ]),
    ]),
    case model.login_error {
      Some(err) -> div([class("text-red-500")], [text("Error: " <> err)])
      None -> element.none()
    },
    button(
      [
        button_class(),
        class("mx-auto"),
        event.on_click(RequestLogin),
        attribute.attribute("type", "submit"),
      ],
      [text("Login")],
    ),
  ])
}
