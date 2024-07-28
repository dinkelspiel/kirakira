import backend/db
import backend/db/post
import backend/db/tag
import backend/db/user
import backend/db/user_like
import backend/db/user_session
import backend/response
import backend/web
import cake
import cake/dialect/mysql_dialect
import cake/fragment as f
import cake/insert as i
import cake/join as j
import cake/param
import cake/select as s
import cake/where as w
import decode
import gleam/bit_array
import gleam/bool
import gleam/dynamic.{type Dynamic}
import gleam/http.{Get, Post}
import gleam/int
import gleam/io
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string_builder
import gmysql
import shared.{Member}
import wisp.{type Request, type Response}

pub fn tags(req: Request) -> Response {
  case req.method {
    Get -> list_tags(req)
    _ -> wisp.method_not_allowed([Get])
  }
}

pub fn list_tags(req: Request) -> Response {
  let result = {
    use tags <- result.try(
      tag.get_tags()
      |> result.replace_error("Problem getting tags from database"),
    )

    Ok(
      json.object([
        #("tags", json.array(tags, fn(tag) { tag.tag_to_json(tag) })),
      ])
      |> json.to_string_builder,
    )
  }

  response.generate_wisp_response(result)
}
