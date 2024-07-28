import backend/db
import backend/db/post
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
) -> Result(CreateComment, dynamic.DecodeErrors) {
  let decoder =
    dynamic.decode2(
      CreateComment,
      dynamic.field("body", dynamic.string),
      dynamic.optional_field("parent_id", dynamic.int),
    )

  decoder(json)
}

fn does_parent_exist_in_post(comment: CreateComment, post_id: Int) {
  case comment.parent_id {
    Some(parent_id) ->
      case
        s.new()
        |> s.selects([s.col("post_comment.body"), s.col("post_comment.user_id")])
        |> s.from_table("post_comment")
        |> s.where(
          w.and([
            w.eq(w.col("post_comment.post_id"), w.int(post_id)),
            w.eq(w.col("post_comment.id"), w.int(parent_id)),
          ]),
        )
        |> s.to_query
        |> db.execute_read(
          [gmysql.to_param(post_id), gmysql.to_param(parent_id)],
          dynamic.tuple2(dynamic.string, dynamic.int),
        )
      {
        Ok(comments) -> Ok(list.length(comments) > 0)

        Error(_) -> Error("Problem selecting comments in post with parent_id")
      }

    None -> Ok(True)
  }
}

fn insert_comment_to_db(comment: CreateComment, user_id: Int, post_id: Int) {
  [
    i.row([
      i.string(comment.body),
      i.int(user_id),
      i.int(post_id),
      case comment.parent_id {
        Some(parent) -> i.int(parent)
        None -> i.null()
      },
    ]),
  ]
  |> i.from_values(table_name: "post_comment", columns: [
    "body", "user_id", "post_id", "parent_id",
  ])
  |> i.to_query
  |> db.execute_write([
    gmysql.to_param(comment.body),
    gmysql.to_param(user_id),
    gmysql.to_param(post_id),
    case comment.parent_id {
      Some(parent_id) -> gmysql.to_param(parent_id)
      None -> gmysql.null_param()
    },
  ])
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

    use _ <- result.try(case
      insert_comment_to_db(comment, auth_user_id, post_id)
    {
      Ok(_) -> Ok(Nil)
      Error(_) -> Error("Problem creating comment")
    })

    Ok(
      json.object([#("message", json.string("Created comment"))])
      |> json.to_string_builder,
    )
  }

  response.generate_wisp_response(result)
}
