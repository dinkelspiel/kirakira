import gleam/http.{Get}
import gleam/json
import gleam/result
import server/db/tag
import server/response
import shared
import wisp.{type Request, type Response}

pub fn tags(req: Request) -> Response {
  case req.method {
    Get -> list_tags_res()
    _ -> wisp.method_not_allowed([Get])
  }
}

pub fn list_tags() -> Result(List(shared.Tag), String) {
  use tags <- result.try(
    tag.get_tags()
    |> result.replace_error("Problem getting tags from database"),
  )

  Ok(tags)
}

fn list_tags_res() -> Response {
  let result = {
    let tags = list_tags()

    case tags {
      Ok(tags) ->
        Ok(
          json.object([
            #("tags", json.array(tags, fn(tag) { tag.tag_to_json(tag) })),
          ])
          |> json.to_string_builder,
        )
      Error(_) -> Error("Problem getting tags from database")
    }
  }

  response.generate_wisp_response(result)
}
