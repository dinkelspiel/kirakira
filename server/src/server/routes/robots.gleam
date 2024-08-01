import wisp.{type Response}

pub fn robots_txt() -> Response {
  wisp.response(200)
  |> wisp.string_body(
    "User-agent: *\nDisallow: /auth\nDisallow: /user\nDisallow: /api\nAllow: /\n \nSitemap: https://kirakira.keii.dev/sitemap.xml\n",
  )
}
