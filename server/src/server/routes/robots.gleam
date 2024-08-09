import webls/robots.{Robot, RobotsConfig}
import wisp.{type Response}

pub fn robots_txt() -> Response {
  let config =
    RobotsConfig(sitemap_url: "https://kirakira.keii.dev/sitemap.xml", robots: [
      Robot(
        user_agent: "*",
        disallowed_routes: ["/auth", "/user", "/api"],
        allowed_routes: ["/"],
      ),
    ])

  wisp.response(200)
  |> wisp.string_body(config |> robots.to_string())
}
