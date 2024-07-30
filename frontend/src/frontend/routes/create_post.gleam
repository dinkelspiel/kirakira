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
import lustre/element/html.{
  a, button, div, form, h1, input, label, li, p, section, span, text, textarea,
  ul,
}
import lustre/event
import shared

pub fn create_post_view(model: Model) {
  section(
    [
      class("flex flex-col mx-auto max-w-[600px]"),
      attribute.id("create_post_form"),
    ],
    [
      h1([class("text-[#584355] font-bold")], [text("Create Post")]),
      form(
        [
          class("w-full gap-4 grid"),
          // this is to force the form to check button enabbled state instead
          event.on("submit", fn(e) {
            event.prevent_default(e)
            Error([])
          }),
        ],
        list.append(
          [
            div(
              [
                class(
                  "grid sm:grid-cols-[170px,1fr] justify-start gap-2 w-full",
                ),
              ],
              [
                label([attribute.for("post_form:title")], [text("Title")]),
                input([
                  input_class(),
                  event.on_input(CreatePostUpdateTitle),
                  attribute.id("post_form:title"),
                  attribute.type_("text"),
                ]),
                label([attribute.for("post_form:by_you")], [
                  text("Is this by you?"),
                ]),
                input([
                  attribute.attribute("type", "checkbox"),
                  attribute.id("post_form:by_you"),
                  event.on_check(CreatePostUpdateOriginalCreator),
                  class("mx-auto accent-[#ffaff3]/50"),
                ]),
                label([attribute.for("post_form:replace_link")], [
                  text("Replace link with body?"),
                ]),
                input([
                  attribute.attribute("type", "checkbox"),
                  attribute.id("post_form:replace_link"),
                  event.on_check(CreatePostUpdateUseBody),
                  class("mx-auto accent-[#ffaff3]/50"),
                ]),
                case model.create_post_use_body {
                  True ->
                    element.fragment([
                      label([attribute.for("post_form:body")], [text("Body")]),
                      textarea(
                        [
                          input_class(),
                          attribute.id("post_form:body"),
                          event.on_input(CreatePostUpdateBody),
                        ],
                        "",
                      ),
                      div([], []),
                      p([class("text-xs leading-tight")], [
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
                      label([attribute.for("post_form:link")], [text("Link")]),
                      input([
                        input_class(),
                        attribute.id("post_form:link"),
                        event.on_input(CreatePostUpdateHref),
                        attribute.type_("url"),
                      ]),
                    ])
                },
              ],
            ),
            div(
              [class("grid sm:grid-cols-2 md:grid-cols-3 gap-4 px-4")],
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
                              tag.permission == shared.Admin
                              && !auth_user.is_admin
                            }
                          None -> False
                        }
                      })
                      |> list.map(fn(tag) {
                        li([], [
                          span([class("flex items-center gap-1 list")], [
                            input([
                              attribute.type_("checkbox"),
                              class("accent-[#ffaff3]/50"),
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
                  || {
                    model.create_post_href == "" && !model.create_post_use_body
                  }
                  || {
                    model.create_post_body == "" && model.create_post_use_body
                  }
                  || list.is_empty(model.create_post_tags),
                ),
                class("mx-auto"),
                event.on_click(RequestCreatePost),
                attribute.type_("submit"),
              ],
              [text("Create Post")],
            ),
            case model.create_post_error {
              Some(err) ->
                p([class("text-red-500 text-center")], [text("Error: " <> err)])
              None -> element.none()
            },
          ],
        ),
      ),
    ],
  )
}
