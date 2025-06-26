import gleam/bool
import gleam/dynamic
import gleam/dynamic/decode
import gleam/http.{Post}
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import server/db
import server/db/user_session
import server/response
import server/sql
import wisp.{type Request, type Response}

pub fn comment(req: Request, post_id: Int) -> Response {
  case req.method {
    Post -> create_comment(req, post_id)
    _ -> wisp.method_not_allowed([Post])
  }
}

type CreateComment {
  CreateComment(body: String, parent_id: Option(Int))
}

fn decode_create_comment(
  json: dynamic.Dynamic,
) -> Result(CreateComment, List(decode.DecodeError)) {
  let decoder = {
    use body <- decode.field("body", decode.string)
    use parent_id <- decode.optional_field(
      "parent_id",
      option.None,
      decode.optional(decode.int),
    )
    decode.success(CreateComment(body:, parent_id:))
  }

  decode.run(json, decoder)
}

fn does_parent_exist_in_post(comment: CreateComment, post_id: Int) {
  use db <- db.get_connection()

  case comment.parent_id {
    Some(parent_id) ->
      case
        sql.get_post_comment_parent_in_post(post_id, parent_id)
        |> db.query(db, _)
      {
        Ok(comments) -> Ok(!list.is_empty(comments.rows))
        Error(_) -> Error("Problem selecting comments in post with parent_id")
      }

    None -> Ok(True)
  }
}

fn insert_comment_to_db(comment: CreateComment, user_id: Int, post_id: Int) {
  use db <- db.get_connection()

  case comment.parent_id {
    Some(parent_id) ->
      sql.create_post_comment(comment.body, user_id, post_id, parent_id)
      |> db.exec(db, _)
      |> result.replace_error("Problem inserting post to database")
    None ->
      sql.create_post_comment_no_parent(comment.body, user_id, post_id)
      |> db.exec(db, _)
      |> result.replace_error("Problem inserting post to database")
  }
}

pub fn create_comment(req: Request, post_id: Int) -> Response {
  use body <- wisp.require_json(req)

  let result = {
    use comment <- result.try(case decode_create_comment(body) {
      Ok(val) -> Ok(val)
      Error(_) -> Error("Invalid body recieved")
    })

    use <- bool.guard(
      when: comment.body == "",
      return: Error("No body provided"),
    )

    use auth_user_id <- result.try(user_session.get_user_id_from_session(req))

    use does_parent_exist_in_parent <- result.try(does_parent_exist_in_post(
      comment,
      post_id,
    ))

    use <- bool.guard(
      when: !does_parent_exist_in_parent,
      return: Error(
        "Comment with specified parent_id doesn't exist in given post",
      ),
    )

    use _ <- result.try(
      case insert_comment_to_db(comment, auth_user_id, post_id) {
        Ok(_) -> Ok(Nil)
        Error(_) -> Error("Problem creating comment")
      },
    )

    Ok(
      json.object([#("message", json.string("Created comment"))])
      |> json.to_string_tree,
    )
  }

  response.generate_wisp_response(result)
}
