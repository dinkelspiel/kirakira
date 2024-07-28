import backend/db
import backend/db/post
import backend/db/post_tag
import backend/db/tag
import backend/db/user
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
import gleam/regex
import gleam/result
import gleam/string_builder
import gmysql
import shared.{Admin, Member}
import wisp.{type Request, type Response}

pub fn posts(req: Request) -> Response {
  // This handler for `/comments` can respond to both GET and POST requests,
  // so we pattern match on the method here.
  case req.method {
    Get -> list_posts(req)
    Post -> create_post(req)
    _ -> wisp.method_not_allowed([Get, Post])
  }
}

pub fn list_posts(req: Request) -> Response {
  let result = {
    let result =
      post.get_posts_query()
      |> post.run_post_query([])

    case result {
      Ok(rows) -> Ok(rows)
      Error(_) -> Error("Selecting posts")
    }
  }

  response.generate_wisp_response(case result {
    Ok(rows) ->
      Ok(
        json.object([
          #(
            "posts",
            post.post_rows_to_post(req, rows, False)
              |> json.array(fn(post) { post.post_to_json(post) }),
          ),
        ])
        |> json.to_string_builder,
      )
    Error(error) -> Error(error)
  })
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
    return: Ok(False),
  )

  case
    s.new()
    |> s.selects([s.col("post.title"), s.col("post.href")])
    |> s.from_table("post")
    |> s.where(
      w.or([
        case post.href {
          Some(href) -> w.eq(w.col("post.href"), w.string(href))
          None -> panic as "Unreachable state because of guard"
        },
      ]),
    )
    |> s.to_query
    |> db.execute_read(
      [
        gmysql.to_param(case post.href {
          Some(href) -> href
          None -> panic as "Unreachable state because of guard"
        }),
      ],
      dynamic.tuple2(dynamic.string, dynamic.string),
    )
  {
    Ok(posts) -> {
      Ok(list.length(posts) > 0)
    }
    Error(_) -> Error("Problem selecting posts with same href")
  }
}

fn insert_post_to_db(req: Request, post: CreatePost, user_id: Int) {
  let _ =
    [
      i.row([
        i.string(post.title),
        case post.href {
          Some(href) -> i.string(href)
          None ->
            case post.body {
              Some(body) -> i.string(body)
              None -> panic as "Unreachable state because of guard"
            }
        },
        i.int(user_id),
        i.bool(post.original_creator),
      ]),
    ]
    |> i.from_values(table_name: "post", columns: [
      "title",
      case post.href {
        Some(_) -> "href"
        None ->
          case post.body {
            Some(_) -> "body"
            None -> panic as "Unreachable state because of guard"
          }
      },
      "user_id",
      "original_creator",
    ])
    |> i.to_query
    |> db.execute_write([
      gmysql.to_param(post.title),
      gmysql.to_param(case post.href {
        Some(href) -> href
        None ->
          case post.body {
            Some(body) -> body
            None -> panic as "Unreachable state because of guard"
          }
      }),
      gmysql.to_param(user_id),
      gmysql.to_param(case post.original_creator {
        False -> 0
        _ -> 1
      }),
    ])

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

    use does_post_with_href_exist <- result.try(does_post_with_href_exist(post))

    use <- bool.guard(
      when: does_post_with_href_exist,
      return: Error("Post with same link already exists"),
    )

    use <- bool.guard(
      when: {
        case post.href {
          Some(href) -> {
            let assert Ok(re) =
              regex.from_string(
                "[-a-zA-Z0-9@:%._\\+~#=]{1,256}\\.[a-zA-Z0-9()]{1,6}\\b([-a-zA-Z0-9()@:%_\\+.~#?&//=]*)",
              )

            !regex.check(re, href)
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
      |> json.to_string_builder,
    )
  }

  response.generate_wisp_response(result)
}
