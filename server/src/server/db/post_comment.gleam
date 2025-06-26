import gleam/float
import gleam/json.{type Json}
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import server/db
import server/db/user_like
import server/sql
import shared.{type PostComment, PostComment}
import shork
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
  use db <- db.get_connection()

  use shork.Returned(_, rows) <- result.try(
    sql.get_post_comments_by_post_id(post_id)
    |> db.query(db, _)
    |> result.replace_error("Database query error"),
  )

  Ok(post_comments_rows_to_post_comments(
    req,
    list.map(rows, fn(row) {
      PostCommentDBRow(
        post_comment_id: row.id,
        post_comment_body: row.body,
        user_username: case row.username {
          Some(a) -> a
          None -> panic
        },
        like_count: row.like_count,
        post_comment_parent_id: row.parent_id,
        post_comment_created_at: row.created_at,
      )
    }),
  ))
}

// id: Int,
// body: String,
// username: String,
// likes: Int,
// user_like_post_comment: Bool,
// parent_id: Option(Int),
// created_at: Int,

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
  use db <- db.get_connection()

  use shork.Returned(_, rows) <- result.try(
    sql.get_post_comments_by_id(post_comment_id)
    |> db.query(db, _)
    |> result.replace_error("Problem getting post_comment by id from database"),
  )

  post_comments_rows_to_post_comments(
    req,
    list.map(rows, fn(row) {
      PostCommentDBRow(
        post_comment_id: row.id,
        post_comment_body: row.body,
        user_username: case row.username {
          Some(a) -> a
          None -> panic
        },
        like_count: row.like_count,
        post_comment_parent_id: row.parent_id,
        post_comment_created_at: row.created_at,
      )
    }),
  )
  |> list.first
  |> result.replace_error(
    "No post_comments found when getting post_comment by id",
  )
}
