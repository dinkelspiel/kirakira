import cake/fragment as f
import cake/join as j
import cake/select as s
import cake/where as w
import decode
import gleam/dynamic.{type Dynamic}
import gleam/json.{type Json}
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gmysql
import server/db.{list_to_tuple}
import server/db/user_like
import shared.{type PostComment, PostComment}
import wisp.{type Request}

pub type PostCommentDBRow {
  PostCommentDBRow(
    post_comment_id: Int,
    post_comment_body: String,
    user_username: String,
    like_count: Int,
    post_comment_parent_id: Option(Int),
    post_comment_created_at: Int,
  )
}

fn get_post_comments_base_query() {
  s.new()
  |> s.selects([
    s.alias(s.col("post_comment.id"), "post_comment_id"),
    s.alias(s.col("post_comment.body"), "post_comment_body"),
    s.alias(s.col("user.username"), "user_username"),
    s.fragment(f.literal(
      "COUNT(DISTINCT user_like_post_comment.id) AS like_count",
    )),
    s.alias(s.col("post_comment.parent_id"), "post_comment_parent_id"),
    s.fragment(f.literal(
      "UNIX_TIMESTAMP(post_comment.created_at) AS post_comment_created_at",
    )),
  ])
  |> s.from_table("post_comment")
  |> s.join(j.left(
    with: j.table("user_like_post_comment"),
    on: w.and([
      w.eq(
        w.col("post_comment.id"),
        w.col("user_like_post_comment.post_comment_id"),
      ),
      w.eq(w.col("user_like_post_comment.status"), w.string("like")),
    ]),
    alias: "user_like_post_comment",
  ))
  |> s.join(j.left(
    with: j.table("user"),
    on: w.eq(w.col("post_comment.user_id"), w.col("user.id")),
    alias: "user",
  ))
  |> s.group_by("post_comment.id")
  |> s.order_by_desc("post_comment.created_at")
}

fn post_comment_db_decoder(data: Dynamic) {
  decode.into({
    use post_comment_id <- decode.parameter
    use post_comment_body <- decode.parameter
    use user_username <- decode.parameter
    use like_count <- decode.parameter
    use post_comment_parent_id <- decode.parameter
    use post_comment_created_at <- decode.parameter

    PostCommentDBRow(
      post_comment_id,
      post_comment_body,
      user_username,
      like_count,
      post_comment_parent_id,
      post_comment_created_at,
    )
  })
  |> decode.field(0, decode.int)
  |> decode.field(1, decode.string)
  |> decode.field(2, decode.string)
  |> decode.field(3, decode.int)
  |> decode.field(4, decode.optional(decode.int))
  |> decode.field(5, decode.int)
  |> decode.from(data |> list_to_tuple)
}

// pub fn get_comments_recursive(post_id: Int) {
//   use comments <- result.try(
//     get_comments_base_query()
//     |> s.where(
//       w.and([
//         w.eq(w.col("post_comment.post_id"), w.int(post_id)),
//         w.is_null(w.col("post_comment.parent_id")),
//       ]),
//     )
//     |> s.to_query
//     |> db.execute_read(
//       [gmysql.to_param("like"), gmysql.to_param(post_id)],
//       fn(data) { comment_db_decoder(data) },
//     ),
//   )
//   Ok(
//     comments
//     |> list.map(fn(db_comment) {
//       Comment(
//         id: db_comment.post_comment_id,
//         body: db_comment.post_comment_body,
//         username: db_comment.user_username,
//         likes: db_comment.like_count,
//         comments: case get_children_of_comment(db_comment.post_comment_id) {
//           Ok(comments) -> comments
//           Error(_) -> []
//         },
//         created_at: db_comment.post_comment_created_at,
//       )
//     }),
//   )
// }

// fn get_children_of_comment(parent_id: Int) {
//   use comments <- result.try(
//     get_comments_base_query()
//     |> s.where(w.eq(w.col("post_comment.parent_id"), w.int(0)))
//     |> s.to_query
//     |> db.execute_read(
//       [gmysql.to_param("like"), gmysql.to_param(parent_id)],
//       fn(data) { comment_db_decoder(data) },
//     ),
//   )
//   Ok(
//     comments
//     |> list.map(fn(db_comment) {
//       Comment(
//         id: db_comment.post_comment_id,
//         body: db_comment.post_comment_body,
//         username: db_comment.user_username,
//         likes: db_comment.like_count,
//         comments: case get_children_of_comment(db_comment.post_comment_id) {
//           Ok(comments) -> comments
//           Error(_) -> []
//         },
//         created_at: db_comment.post_comment_created_at,
//       )
//     }),
//   )
// }

pub fn get_post_comments(req: Request, post_id: Int) {
  use comments <- result.try(
    get_post_comments_base_query()
    |> s.where(w.eq(w.col("post_comment.post_id"), w.int(post_id)))
    |> s.to_query
    |> db.execute_read(
      [gmysql.to_param("like"), gmysql.to_param(post_id)],
      fn(data) { post_comment_db_decoder(data) },
    ),
  )
  Ok(post_comments_rows_to_post_comments(req, comments))
}

fn post_comments_rows_to_post_comments(
  req: Request,
  post_comments: List(PostCommentDBRow),
) {
  list.map(post_comments, fn(db_comment) {
    PostComment(
      id: db_comment.post_comment_id,
      body: db_comment.post_comment_body,
      username: db_comment.user_username,
      likes: db_comment.like_count,
      user_like_post_comment: user_like.get_auth_user_likes(
        req,
        db_comment.post_comment_id,
        user_like.PostComment,
      ),
      parent_id: db_comment.post_comment_parent_id,
      created_at: db_comment.post_comment_created_at,
    )
  })
}

pub fn post_comments_to_json(post_comments: List(PostComment)) -> Json {
  json.array(post_comments, fn(post_comment) {
    json.object([
      #("id", json.int(post_comment.id)),
      #("body", json.string(post_comment.body)),
      #("username", json.string(post_comment.username)),
      #("likes", json.int(post_comment.likes)),
      #(
        "user_like_post_comment",
        json.bool(post_comment.user_like_post_comment),
      ),
      #("parent_id", case post_comment.parent_id {
        Some(parent_id) -> json.int(parent_id)
        None -> json.null()
      }),
      #("created_at", json.int(post_comment.created_at)),
    ])
  })
}

pub fn get_post_comment_by_id(
  req: Request,
  post_comment_id: Int,
) -> Result(PostComment, String) {
  use post_comment_rows <- result.try(
    get_post_comments_base_query()
    |> s.where(w.eq(w.col("post_comment.id"), w.int(post_comment_id)))
    |> s.to_query
    |> db.execute_read(
      [gmysql.to_param("like"), gmysql.to_param(post_comment_id)],
      fn(data) { post_comment_db_decoder(data) },
    )
    |> result.replace_error("Problem getting post_comment by id from database"),
  )

  post_comments_rows_to_post_comments(req, post_comment_rows)
  |> list.first
  |> result.replace_error(
    "No post_comments found when getting post_comment by id",
  )
}
