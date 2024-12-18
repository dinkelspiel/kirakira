import gleam/json
import gleam/string_tree.{type StringTree}
import wisp

pub fn generate_wisp_response(result: Result(StringTree, String)) {
  case result {
    Ok(json) -> wisp.json_response(json, 200)
    Error(error) ->
      wisp.json_response(
        json.object([#("error", json.string(error))])
          |> json.to_string_tree,
        200,
      )
  }
}

pub fn error(error: String) {
  wisp.json_response(
    json.object([#("error", json.string(error))])
      |> json.to_string_tree,
    400,
  )
}
