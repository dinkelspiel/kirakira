import frontend/components/button.{button_class}
import frontend/state.{type Model, RequestCreateAuthCode, RequestLogout}
import gleam/option.{None, Some}
import lustre/attribute.{class}
import lustre/element/html.{button, div, text}
import lustre/event

pub fn user_view(model: Model) {
  div([class("flex gap-2")], [
    button([button_class(), event.on_click(RequestLogout)], [text("Logout")]),
    case model.invite_link {
      Some(link) -> text(link)
      None ->
        button([button_class(), event.on_click(RequestCreateAuthCode)], [
          text("Create Invite Link"),
        ])
    },
  ])
}
