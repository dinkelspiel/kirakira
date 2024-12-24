import gleam/io
import gleam/list
import lucide_lustre
import lustre
import lustre/attribute.{class, href, id, src}
import lustre/effect.{type Effect}
import lustre/element.{type Element, text}
import lustre/element/html.{a, body, footer, img, nav, p, span}

pub fn main() {
  io.print("")
}

pub fn initialize(content: fn() -> Element(a)) {
  html.div([], [
    html.style(
      [],
      "
.hermodr-list {
  transition: all;
  transition-duration: 400ms;
}

.hermodr-list > * {
  transition: all;
  transition-duration: 400ms;
}

.hermodr-list > :not(:last-child) {
  margin-bottom: -11%;
}

.hermodr-list:not(:hover) > :nth-child(3) {
  scale: 1;
}

.hermodr-list:not(:hover) > :nth-child(2) {
  scale: 0.95;
}

.hermodr-list:not(:hover) > :nth-child(1) {
  scale: 0.9;
}",
    ),
    content(),
    html.ol(
      [
        attribute.class(
          "hermodr-list group hover:mb-[0.6rem] flex flex-col fixed bottom-8 right-8",
        ),
      ],
      html.li(
        [
          attribute.style([
            #("box-shadow", "rgba(0, 0, 0, 0.1) 0px 4px 12px 0px"),
          ]),
          attribute.class(
            "rounded-lg border-[rgb(237,_237,_237)] group-hover:mb-[14px] border w-[356px] h-[53px] bg-white",
          ),
        ],
        [lucide_lustre.circle_check([])],
      )
        |> list.repeat(3),
    ),
  ])
}
