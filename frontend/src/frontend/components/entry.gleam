import birl
import frontend/components/like.{like_button_view}
import frontend/components/tag.{tag_view}
import frontend/state.{RequestLikePost}
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import lustre/attribute.{class, href}
import lustre/element.{text}
import lustre/element/html.{a, div, li}
import shared.{type Post}

pub fn entry_view(post: Post) {
  li([class("grid grid-cols-[18px,1fr] gap-2")], [
    like_button_view(
      post.user_like_post,
      post.likes,
      RequestLikePost(post.id),
      "",
    ),
    div([class("flex flex-col gap-1")], [
      div([class("flex flex-col sm:flex-row sm:gap-2 sm:items-center")], [
        a(
          [
            class("text-[#584355] font-bold"),
            href(case post.href {
              Some(post_href) -> post_href
              None -> "/post/" <> { post.id |> int.to_string }
            }),
          ],
          [text(post.title)],
        ),
        case post.body {
          Some(post_body) ->
            a(
              [
                attribute.attribute("title", post_body),
                class("text-xs text-neutral-500"),
              ],
              [text("☶")],
            )
          None -> element.none()
        },
        div(
          [class("flex gap-2 items-center")],
          list.append(post.tags |> list.map(fn(tag) { tag_view(tag) }), [
            case post.href {
              Some(post_href) ->
                a([class("text-xs text-neutral-500 italic"), href(post_href)], [
                  text(post_href),
                ])
              None -> element.none()
            },
          ]),
        ),
      ]),
      div([class("flex items-center gap-2")], [
        // div([class("size-4 rounded-full bg-neutral-200")], []),
        div([class("text-neutral-500 text-xs")], [
          text(
            case post.original_creator {
              True -> "authored by"
              False -> "via"
            }
            <> " "
            <> post.username
            <> " "
            <> birl.legible_difference(
              birl.now(),
              birl.from_unix(post.created_at),
            ),
          ),
        ]),
        a(
          [
            class("text-neutral-500 text-xs border-s border-s-neutral-400 ps-2"),
            href("/post/" <> post.id |> int.to_string),
          ],
          [
            text(
              post.comments_count |> int.to_string
              <> case post.comments_count != 1 {
                True -> " comments"
                False -> " comment"
              },
            ),
          ],
        ),
      ]),
    ]),
  ])
}
