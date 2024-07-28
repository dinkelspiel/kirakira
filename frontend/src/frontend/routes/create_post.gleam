import frontend/components/button.{button_class}
import frontend/components/input.{input_class}
import frontend/components/tag.{tag_view}
import frontend/state.{
  type Model, CreatePostUpdateBody, CreatePostUpdateHref,
  CreatePostUpdateOriginalCreator, CreatePostUpdateTags, CreatePostUpdateTitle,
  CreatePostUpdateUseBody, RequestCreatePost,
}
import gleam/list
import gleam/option.{None, Some}
import lustre/attribute.{class, href}
import lustre/element
import lustre/element/html.{a, button, div, h1, input, li, text, textarea, ul}
import lustre/event
import shared

pub fn create_post_view(model: Model) {
  div(
    [class("flex flex-col  mx-auto max-w-[450px] w-full gap-4")],
    list.append(
      [
        h1([class("text-[#584355] font-bold")], [text("Create Post")]),
        div(
          [class("grid sm:grid-cols-[170px,1fr] justify-start gap-2 w-full")],
          [
            div([], [text("Title")]),
            input([input_class(), event.on_input(CreatePostUpdateTitle)]),
            div([], [text("Is this by you?")]),
            input([
              attribute.attribute("type", "checkbox"),
              event.on_check(CreatePostUpdateOriginalCreator),
              class("me-auto"),
            ]),
            div([], [text("Replace link with body?")]),
            input([
              attribute.attribute("type", "checkbox"),
              event.on_check(CreatePostUpdateUseBody),
              class("me-auto"),
            ]),
            case model.create_post_use_body {
              True ->
                element.fragment([
                  div([], [text("Body")]),
                  textarea(
                    [input_class(), event.on_input(CreatePostUpdateBody)],
                    "",
                  ),
                  div([], []),
                  div([class("text-xs leading-tight")], [
                    text(
                      "Kirakira is above all else a showcase or sharing forum. If you are going to ask for help with gleam refer to the ",
                    ),
                    a(
                      [
                        href("https://discord.gg/Fm8Pwmy"),
                        class("hover:underline text-cyan-700"),
                      ],
                      [text("gleam discord.")],
                    ),
                  ]),
                ])
              False ->
                element.fragment([
                  div([], [text("Link")]),
                  input([input_class(), event.on_input(CreatePostUpdateHref)]),
                ])
            },
          ],
        ),
        case model.create_post_error {
          Some(err) -> div([class("text-red-500")], [text("Error: " <> err)])
          None -> element.none()
        },
        div(
          [class("grid sm:grid-cols-2 gap-4 px-4")],
          list.map(shared.tag_categories, fn(category) {
            div([], [
              html.h2([class("underline text-lg font-semibold")], [
                text(shared.tag_category_to_string(category)),
              ]),
              ul(
                [class("list-disc")],
                list.filter(model.tags, fn(tag) { tag.category == category })
                  |> list.filter(fn(tag) {
                    case model.auth_user {
                      Some(auth_user) ->
                        !{
                          tag.permission == shared.Admin && !auth_user.is_admin
                        }
                      None -> False
                    }
                  })
                  |> list.map(fn(tag) {
                    li([], [
                      div([class("flex items-center gap-1 list")], [
                        input([
                          attribute.type_("checkbox"),
                          attribute.checked(list.contains(
                            model.create_post_tags,
                            tag.id,
                          )),
                          event.on_click(CreatePostUpdateTags(tag.id)),
                        ]),
                        tag_view(tag.name),
                      ]),
                    ])
                  }),
              ),
            ])
          }),
        ),
      ],
      [
        button(
          [
            button_class(),
            attribute.disabled(
              model.create_post_title == ""
              || { model.create_post_href == "" && !model.create_post_use_body }
              || { model.create_post_body == "" && model.create_post_use_body }
              || list.is_empty(model.create_post_tags),
            ),
            class("mx-auto"),
            event.on_click(RequestCreatePost),
          ],
          [text("Create Post")],
        ),
      ],
    ),
  )
}
