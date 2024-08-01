import lustre/attribute.{attribute, href, id, name, rel, src}
import lustre/element
import lustre/element/html.{body, head, html, link, meta, script, title}

pub fn page_scaffold(content: element.Element(a)) {
  html([], [
    head([], [
      meta([attribute("charset", "UTF-8")]),
      meta([
        attribute("content", "width=device-width, initial-scale=1.0"),
        name("viewport"),
      ]),
      title([], "📋 Kirakira"),
      meta([
        attribute("content", "A forum made in Gleam for the Gleam community"),
        name("description"),
      ]),
      meta([attribute("content", "max-image-preview:large"), name("robots")]),
      meta([attribute("content", "en_US"), attribute("property", "og:locale")]),
      meta([
        attribute("content", "📋 Kirakira"),
        attribute("property", "og:site_name"),
      ]),
      meta([attribute("content", "website"), attribute("property", "og:type")]),
      meta([
        attribute("content", "📋 Kirakira"),
        attribute("property", "og:title"),
      ]),
      meta([
        attribute("content", "A forum made in Gleam for the Gleam community"),
        attribute("property", "og:description"),
      ]),
      meta([
        attribute("content", "https://kirakira.keii.dev/"),
        attribute("property", "og:url"),
      ]),
      meta([attribute("content", "summary"), name("twitter:card")]),
      meta([attribute("content", "📋 Kirakira"), name("twitter:title")]),
      meta([
        attribute("content", "A forum made in Gleam for the Gleam community"),
        name("twitter:description"),
      ]),
      link([
        href("/priv/static/favicon.ico"),
        attribute.type_("image/x-icon"),
        rel("icon"),
      ]),
      link([href("/static/client.min.css"), rel("stylesheet")]),
      script([src("/static/client.min.mjs"), attribute.type_("module")], ""),
      script(
        [
          src("https://plausible.keii.dev/js/script.js"),
          attribute("data-domain", "kirakira.keii.dev"),
          attribute("defer", ""),
        ],
        "",
      ),
    ]),
    body([id("app")], [content]),
  ])
}
