import gleam/bool
import gleam/dynamic
import gleam/http.{Get, Post}
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/regexp
import gleam/result
import server/db
import server/db/post
import server/db/post_tag
import server/db/tag
import server/db/user
import server/db/user_session
import server/response
import shared.{Admin}
import squirrels/sql
import wisp.{type Request, type Response}

pub fn posts(req: Request) -> Response {
  // This handler for `/comments` can respond to both GET and POST requests,
  // so we pattern match on the method here.
  case req.method {
    Get -> list_posts_res(req)
    Post -> create_post(req)
    _ -> wisp.method_not_allowed([Get, Post])
  }
}

pub fn list_posts_res(req: Request) -> Response {
  let result = case post.get_posts(req) {
    Ok(posts) ->
      Ok(
        json.object([
          #(
            "posts",
            posts
              |> json.array(fn(post) { post.post_to_json(post) }),
          ),
        ])
        |> json.to_string_tree,
      )
    Error(error) -> Error(error)
  }

  response.generate_wisp_response(result)
}

type CreatePost {
  CreatePost(
    title: String,
    href: Option(String),
    body: Option(String),
    original_creator: Bool,
    tags: List(Int),
  )
}

fn decode_create_post(
  json: dynamic.Dynamic,
) -> Result(CreatePost, dynamic.DecodeErrors) {
  let decoder =
    dynamic.decode5(
      CreatePost,
      dynamic.field("title", dynamic.string),
      dynamic.optional_field("href", dynamic.string),
      dynamic.optional_field("body", dynamic.string),
      dynamic.field("original_creator", dynamic.bool),
      dynamic.field("tags", dynamic.list(dynamic.int)),
    )

  decoder(json)
}

fn does_post_with_href_exist(post: CreatePost) {
  use <- bool.guard(
    when: case post.href {
      Some(_) -> False
      None -> True
    },
    return: False,
  )

  case db.get_connection_raw() {
    Ok(db_connection) ->
      case post.href {
        Some(href) ->
          case sql.get_post_by_href(db_connection, href) {
            Ok(posts) -> !list.is_empty(posts.rows)
            Error(_) -> False
          }
        None -> False
      }
    Error(_) -> False
  }
}

fn insert_post_to_db(req: Request, post: CreatePost, user_id: Int) {
  use db_connection <- db.get_connection()

  let _ = case post.href {
    Some(href) ->
      sql.create_post_with_href(
        db_connection,
        post.title,
        href,
        user_id,
        post.original_creator,
      )
    None ->
      case post.body {
        Some(body) ->
          sql.create_post_with_body(
            db_connection,
            post.title,
            body,
            user_id,
            post.original_creator,
          )
        None -> panic as "Unreachable state because of guard"
      }
  }

  use latest_post <- result.try(post.get_latest_post_by_user(req, user_id))

  list.map(post.tags, fn(tag) { post_tag.create_post_tag(latest_post.id, tag) })

  Ok(Nil)
}

pub fn create_post(req: Request) -> Response {
  use body <- wisp.require_json(req)

  let result = {
    use post <- result.try(case decode_create_post(body) {
      Ok(val) -> Ok(val)
      Error(_) -> Error("Invalid body recieved")
    })

    use <- bool.guard(
      when: case post.href {
        Some(_) -> False
        None ->
          case post.body {
            Some(_) -> False
            None -> True
          }
      },
      return: Error("Neither body nor href provided"),
    )

    use <- bool.guard(
      when: post.title == "",
      return: Error("No title provided"),
    )

    use auth_user_id <- result.try(user_session.get_user_id_from_session(req))

    let user_is_admin = user.is_user_admin(auth_user_id)

    use <- bool.guard(
      when: does_post_with_href_exist(post),
      return: Error("Post with same link already exists"),
    )

    use <- bool.guard(
      when: {
        case post.href {
          Some(href) -> {
            let assert Ok(re) =
              regexp.from_string(
                "[-a-zA-Z0-9@:%._\\+~#=]{1,256}\\.[a-zA-Z0-9()]{1,6}\\b([-a-zA-Z0-9()@:%_\\+.~#?&//=]*)",
              )

            !regexp.check(re, href)
          }
          None -> False
        }
      },
      return: Error("Invalid url provided"),
    )

    let tags =
      post.tags
      |> list.map(fn(tag) { tag.get_tag_by_id(tag) })

    use <- bool.guard(
      when: list.is_empty(tags),
      return: Error("Atleast one tag must be provided"),
    )

    use <- bool.guard(
      when: list.any(tags, fn(tag) {
        case tag {
          Ok(tag) -> tag.permission == Admin && !user_is_admin
          Error(_) -> True
        }
      }),
      return: Error(
        "Atleast one of the tags provided was invalid or you lacked permission to add it",
      ),
    )

    use _ <- result.try(case insert_post_to_db(req, post, auth_user_id) {
      Ok(_) -> Ok(Nil)
      Error(_) -> Error("Problem creating post")
    })

    Ok(
      json.object([#("message", json.string("Created post"))])
      |> json.to_string_tree,
    )
  }

  response.generate_wisp_response(result)
}
