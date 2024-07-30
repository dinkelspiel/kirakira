import frontend/components/button.{button_class}
import frontend/components/input.{input_class}
import frontend/state.{
  type Model, RequestSignUp, SignUpUpdateEmail, SignUpUpdatePassword,
  SignUpUpdateUsername,
}
import gleam/option.{None, Some}
import lustre/attribute.{class}
import lustre/element.{text}
import lustre/element/html.{button, div, form, h1, input, label, p}
import lustre/event

pub fn signup_view(model: Model, auth_code _: String) {
  div([class("flex flex-col  mx-auto max-w-[450px] w-full gap-4")], [
    div([class("flex flex-col gap-2")], [
      h1([class("text-[#584355] font-bold")], [text("Create your account")]),
      p([class("text-sm text-neutral-500")], [
        text("You have been invited by " <> model.inviter),
      ]),
    ]),
    form([class("grid gap-2 w-full"), event.on_submit(RequestSignUp)], [
      label([], [text("Username")]),
      input([
        input_class(),
        event.on_input(SignUpUpdateUsername),
        attribute.type_("text"),
        attribute.attribute("autocomplete", "username"),
      ]),
      div([], [text("E-mail")]),
      input([
        input_class(),
        event.on_input(SignUpUpdateEmail),
        attribute.type_("email"),
        attribute.attribute("autocomplete", "email"),
      ]),
      label([], [text("Password")]),
      input([
        input_class(),
        event.on_input(SignUpUpdatePassword),
        attribute.attribute("type", "password"),
        attribute.attribute("autocomplete", "new-password"),
      ]),
      button(
        [
          button_class(),
          class("mx-auto"),
          attribute.attribute("type", "submit"),
        ],
        [text("Sign up")],
      ),
    ]),
    case model.sign_up_error {
      Some(err) -> p([class("text-red-500")], [text("Error: " <> err)])
      None -> element.none()
    },
  ])
}
