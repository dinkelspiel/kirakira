import backend/db/tag
import backend/response
import gleam/http.{Get}
import gleam/json
import gleam/result
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
