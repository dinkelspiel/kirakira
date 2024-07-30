import frontend/components/entry.{entry_view}
import frontend/state.{type Model}
import gleam/list
import lustre/attribute.{class}
import lustre/element/html.{section, ul}

pub fn latest_view(model: Model) {
  section([attribute.id("latest")], [
    ul(
      [class("flex flex-col gap-2")],
      model.posts
        |> list.map(fn(post) { entry_view(post) }),
    ),
  ])
}
