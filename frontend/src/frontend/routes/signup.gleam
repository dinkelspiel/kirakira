import frontend/components/button.{button_class}
import frontend/components/input.{input_class}
import frontend/state.{
  type Model, RequestSignUp, SignUpUpdateEmail, SignUpUpdatePassword,
  SignUpUpdateUsername,
}
import gleam/option.{None, Some}
import lustre/attribute.{class}
import lustre/element
import lustre/element/html.{button, div, h1, input, text}
import lustre/event

pub fn signup_view(model: Model, auth_code _: String) {
  div([class("flex flex-col mx-auto max-w-[450px] w-full gap-4")], [
    div([class("flex flex-col gap-2")], [
      h1([class("text-[#584355] font-bold")], [text("Create your account")]),
      div([class("text-sm text-neutral-500")], [
        text("You have been invited by " <> model.inviter),
      ]),
    ]),
    div([class("grid lg:grid-cols-[170px,1fr] gap-2 w-full")], [
      div([], [text("Username")]),
      input([input_class(), event.on_input(SignUpUpdateUsername)]),
      div([], [text("E-mail")]),
      input([input_class(), event.on_input(SignUpUpdateEmail)]),
      div([], [text("Password")]),
      input([
        input_class(),
        event.on_input(SignUpUpdatePassword),
        attribute.attribute("type", "password"),
      ]),
    ]),
    case model.sign_up_error {
      Some(err) -> div([class("text-red-500")], [text("Error: " <> err)])
      None -> element.none()
    },
    button([button_class(), class("mx-auto"), event.on_click(RequestSignUp)], [
      text("Sign up"),
    ]),
  ])
}
