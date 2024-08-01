import client/components/button.{button_class}
import client/state.{type Model, RequestCreateAuthCode, RequestLogout}
import gleam/option.{None, Some}
import lustre/attribute.{class}
import lustre/element/html.{button, section, text}
import lustre/event

pub fn user_view(model: Model) {
  section([class("flex gap-2"), attribute.id("user_settings")], [
    button(
      [button_class(), event.on_click(RequestLogout), attribute.type_("button")],
      [text("Logout")],
    ),
    case model.invite_link {
      Some(link) -> text(link)
      None ->
        button(
          [
            button_class(),
            event.on_click(RequestCreateAuthCode),
            attribute.type_("button"),
          ],
          [text("Create Invite Link")],
        )
    },
  ])
}
