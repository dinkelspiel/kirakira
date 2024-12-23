import gleam/io
import lustre
import lustre/attribute.{class, href, id, src}
import lustre/effect.{type Effect}
import lustre/element.{type Element, text}
import lustre/element/html.{a, body, footer, img, nav, p, span}

pub fn initialize(a: fn() -> Element(a)) {
  html.div([], [
    a(),
    html.div([attribute.class("fixed top-0 bg-black size-10")], []),
  ])
}
