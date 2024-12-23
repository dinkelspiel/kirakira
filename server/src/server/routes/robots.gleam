import webls/robots
import wisp.{type Response}

pub fn robots_txt() -> Response {
  wisp.response(200)
  |> wisp.string_body(
    robots.config("https://kirakira.keii.dev/sitemap.xml")
    |> robots.with_config_robot(
      robots.robot("*")
      |> robots.with_robot_allowed_route("/")
      |> robots.with_robot_disallowed_routes(["/auth", "/user", "/api"]),
    )
    |> robots.to_string(),
  )
}
