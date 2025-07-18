import client/components/button.{button_class}
import client/components/input.{input_class}
import client/state.{
  type Model, RequestSignUp, SignUpUpdateEmail, SignUpUpdatePassword,
  SignUpUpdateUsername,
}
import gleam/option.{None, Some}
import lustre/attribute.{class}
import lustre/element.{text}
import lustre/element/html.{button, div, form, h1, input, label, p, section}
import lustre/event

pub fn signup_view(model: Model, auth_code _: String) {
  section(
    [
      class("flex flex-col mx-auto max-w-[450px] w-full gap-4"),
      attribute.id("signup_form"),
    ],
    [
      div([class("flex flex-col gap-2")], [
        h1([class("text-[#584355] font-bold")], [text("Create your account")]),
        p([class("text-sm text-neutral-500")], [
          text("You have been invited by " <> model.inviter),
        ]),
      ]),
      form(
        [class("grid gap-2 w-full"), event.on_submit(fn(_) { RequestSignUp })],
        [
          label([attribute.for("signup_form:username")], [text("Username")]),
          input([
            input_class(),
            event.on_input(SignUpUpdateUsername),
            attribute.id("signup_form:username"),
            attribute.type_("text"),
            attribute.attribute("autocomplete", "username"),
          ]),
          label([attribute.for("signup_form:email")], [text("E-mail")]),
          input([
            input_class(),
            event.on_input(SignUpUpdateEmail),
            attribute.id("signup_form:email"),
            attribute.type_("email"),
            attribute.attribute("autocomplete", "email"),
          ]),
          label([attribute.for("signup_form:password")], [text("Password")]),
          input([
            input_class(),
            event.on_input(SignUpUpdatePassword),
            attribute.id("signup_form:password"),
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
          case model.sign_up_error {
            Some(err) ->
              p([class("text-red-500 text-center")], [text("Error: " <> err)])
            None -> element.none()
          },
        ],
      ),
    ],
  )
}
