import birl
import frontend/components/button.{button_class}
import frontend/components/entry.{entry_view}
import frontend/components/input.{input_class}
import frontend/components/like.{like_button_view}
import frontend/lib/time
import frontend/state.{
  type Model, CreateCommentUpdateBody, CreateCommentUpdateParentId,
  RequestCreateComment, RequestLikeComment,
}
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import lustre/attribute.{class, id}
import lustre/element
import lustre/element/html.{
  button, div, form, li, p, section, span, text, textarea, time,
}
import lustre/event
import shared.{type PostComment}

fn create_comment_view(model: Model) {
  form([class("grid gap-2")], [
    textarea(
      [
        input_class(),
        event.on_input(CreateCommentUpdateBody),
        class("max-w-[60ch]"),
        ..case model.auth_user {
          None -> [
            attribute.placeholder("You must be logged in to leave a comment"),
            attribute.disabled(True),
          ]
          _ -> []
        }
      ],
      "",
    ),
    button(
      [
        button_class(),
        event.on_click(RequestCreateComment),
        case model.auth_user {
          None -> attribute.disabled(True)
          _ -> attribute.none()
        },
        attribute.type_("submit"),
      ],
      [text("Post")],
    ),
    case model.create_comment_error {
      Some(err) ->
        p([class("text-red-500 text-center")], [text("Error: " <> err)])
      None -> element.none()
    },
  ])
}

pub fn show_post_view(model: Model) {
  case model.show_post {
    Some(post) ->
      section([class("grid gap-4"), attribute.id("thread")], [
        entry_view(post),
        div([class("ps-[18px] grid gap-4 pb-4")], [
          case post.body {
            Some(body) -> div([class("text-sm")], [text(body)])
            None -> element.none()
          },
          case model.create_comment_parent_id {
            None -> create_comment_view(model)
            _ ->
              button(
                [
                  class("text-xs text-neutral-500 me-auto"),
                  attribute.type_("button"),
                  event.on_click(CreateCommentUpdateParentId(None)),
                ],
                [text("Reset reply")],
              )
          },
        ]),
        ..comments_view(model, post.comments, None)
      ])
    None -> div([], [text("Loading...")])
  }
}

fn comments_view(
  model: Model,
  comments: List(PostComment),
  parent_id: Option(Int),
) {
  comments
  |> list.filter(fn(comment) { comment.parent_id == parent_id })
  |> list.map(fn(comment) {
    li(
      [
        class("ps-[18px] flex flex-col gap-2 border-s border-s-neutral-200"),
        id("comment-" <> int.to_string(comment.id)),
      ],
      [
        div([class("flex flex-col gap-1")], [
          span(
            [class("flex items-center gap-2 text-neutral-500 text-xs relative")],
            [
              like_button_view(
                comment.user_like_post_comment,
                comment.likes,
                RequestLikeComment(comment.id),
                "absolute -left-[18px] -translate-x-1/2 bg-white pb-1 translate-y-2 pt-3",
              ),
              span([], [
                text(comment.username <> " "),
                time(
                  [
                    attribute.attribute(
                      "datetime",
                      comment.created_at
                        |> birl.from_unix()
                        |> birl.to_iso8601(),
                    ),
                  ],
                  [
                    text(time.legible_difference(
                      birl.now(),
                      birl.from_unix(comment.created_at),
                    )),
                  ],
                ),
              ]),
              button(
                [
                  class("border-s border-s-neutral-400 ps-2"),
                  event.on_click(CreateCommentUpdateParentId(Some(comment.id))),
                ],
                [text("reply")],
              ),
            ],
          ),
          p([class("pb-2")], [text(comment.body)]),
          case model.create_comment_parent_id {
            Some(parent_id) if parent_id == comment.id ->
              create_comment_view(model)
            _ -> element.none()
          },
        ]),
        ..comments_view(model, comments, Some(comment.id))
      ],
    )
  })
}
