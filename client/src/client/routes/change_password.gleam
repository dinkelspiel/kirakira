import client/components/button.{button_class}
import client/components/input.{input_class}
import client/state.{type Model, LoginUpdatePassword, RequestChangePassword}
import gleam/option.{None, Some}
import lustre/attribute.{class, id, type_}
import lustre/element
import lustre/element/html.{button, div, form, h1, input, label, section, text}
import lustre/event

pub fn change_password(model: Model) {
  section([class("flex flex-col mx-auto max-w-[450px] w-full gap-4")], [
    h1([class("text-[#584355] font-bold")], [
      text("Change Password for " <> model.change_password_target),
    ]),
    form([class("grid gap-2 w-full"), event.on_submit(RequestChangePassword)], [
      label([attribute.for("change_password_form:password")], [
        text("New Password"),
      ]),
      input([
        input_class(),
        event.on_input(LoginUpdatePassword),
        id("change_password_form:password"),
        type_("password"),
        attribute.attribute("autocomplete", "current-password"),
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
          text("Change Password"),
        ]),
      ]),
    ]),
  ])
}
