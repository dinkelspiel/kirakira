import client/components/button.{button_class}
import client/components/input.{input_class}
import client/state.{type Model, LoginUpdateEmailUsername, RequestForgotPassword}
import gleam/option.{None, Some}
import lustre/attribute.{class, href, id, type_, value}
import lustre/element
import lustre/element/html.{
  a, button, div, form, h1, input, label, section, text,
}
import lustre/event

pub fn forgot_password(model: Model) {
  section([class("flex flex-col mx-auto max-w-[450px] w-full gap-4")], [
    h1([class("text-[#584355] font-bold")], [text("Forgot Password")]),
    form(
      [
        class("grid gap-2 w-full"),
        event.on_submit(fn(_) { RequestForgotPassword }),
      ],
      [
        label([attribute.for("forgot_password_form:email")], [text("E-mail")]),
        input([
          input_class(),
          event.on_input(LoginUpdateEmailUsername),
          id("forgot_password_form:email"),
          type_("text"),
          attribute.attribute("autocomplete", "email"),
          value(model.login_email_username),
        ]),
        case model.forgot_password_response {
          Some(response) ->
            case response {
              Ok(response) -> div([class("text-green-700")], [text(response)])
              Error(response) -> div([class("text-red-700")], [text(response)])
            }
          None -> element.none()
        },
        div([class("flex justify-between items-center mt-2")], [
          button([button_class(), attribute.attribute("type", "submit")], [
            text("Request"),
          ]),
          a([href("/auth/login"), class("ms-auto text-[#584355]")], [
            text("Back to Login"),
          ]),
        ]),
      ],
    ),
  ])
}
