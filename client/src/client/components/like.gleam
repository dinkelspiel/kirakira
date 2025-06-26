import client/state.{
  type Msg, LikeCommentResponded, LikePostResponded, message_error_decoder,
}
import env
import gleam/int
import gleam/json
import lustre/attribute.{class}
import lustre/element.{text}
import lustre/element/html.{button, div, label}
import lustre/event
import lustre_http

pub fn like_button_view(user_likes: Bool, likes: Int, msg: Msg, classes: String) {
  button(
    [
      class("flex flex-col justify-center items-center"),
      class(classes),
      event.on_click(msg),
      attribute.type_("button"),
    ],
    [
      div(
        [
          attribute.styles([
            #("width", "0"),
            #("height", "0"),
            #("border-left", "5px solid transparent"),
            #("border-right", "5px solid transparent"),
            #(
              "border-bottom",
              "10px solid "
                <> case user_likes {
                True -> "#000000"
                False -> "#939393"
              },
            ),
          ]),
        ],
        [],
      ),
      label([class("text-xs text-neutral-500")], [text(likes |> int.to_string)]),
    ],
  )
}

pub fn like_post(post_id: Int) {
  lustre_http.post(
    env.get_api_url() <> "/api/posts/" <> int.to_string(post_id) <> "/likes",
    json.object([]),
    lustre_http.expect_json(message_error_decoder(), LikePostResponded),
  )
}

pub fn like_comment(post_comment_id: Int) {
  lustre_http.post(
    env.get_api_url()
      <> "/api/posts/comments/"
      <> int.to_string(post_comment_id)
      <> "/likes",
    json.object([]),
    lustre_http.expect_json(message_error_decoder(), LikeCommentResponded),
  )
}
