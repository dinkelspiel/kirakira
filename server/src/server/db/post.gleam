import gleam/float
import gleam/int
import gleam/json.{type Json}
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import server/db
import server/db/post_comment
import server/db/user_like
import shared.{type Post, Post}
import squirrels/sql
import wisp.{type Request}

pub type ListPostsDBRow {
  ListPostsDBRow(
    post_id: Int,
    post_title: String,
    post_href: Option(String),
    post_body: Option(String),
    user_username: String,
    post_original_creator: Bool,
    like_count: Int,
    comment_count: Int,
    created_at: Int,
  )
}

pub fn get_tags_for_post(post_id: Int) {
  case sql.get_tags_by_post_id(db.get_connection(), post_id) {
    Ok(returned) ->
      Ok(
        list.map(returned.rows, fn(a) {
          case a.name {
            Some(name) -> name
            None -> panic
          }
        }),
      )
    Error(_) -> Error("Problem getting tags for " <> post_id |> int.to_string)
  }
}

import gleam/io

pub fn post_rows_to_post(
  req: Request,
  rows: List(ListPostsDBRow),
  with_comments: Bool,
) -> List(Post) {
  rows
  |> list.map(fn(row) {
    Post(
      id: row.post_id,
      title: row.post_title,
      href: row.post_href,
      body: row.post_body,
      username: row.user_username,
      original_creator: row.post_original_creator,
      likes: row.like_count,
      user_like_post: user_like.get_auth_user_likes(
        req,
        row.post_id,
        user_like.Post,
      ),
      comments_count: row.comment_count,
      comments: case with_comments {
        True ->
          case post_comment.get_post_comments(req, row.post_id) {
            Ok(comments) -> comments
            Error(err) -> {
              io.debug(err)
              panic as "fuck"
            }
          }
        False -> []
      },
      tags: case get_tags_for_post(row.post_id) {
        Ok(tags) -> tags
        Error(_) -> panic as "Problem getting tags"
      },
      created_at: row.created_at,
    )
  })
}

pub fn post_to_json(post: Post) -> Json {
  json.object([
    #("id", json.int(post.id)),
    #("title", json.string(post.title)),
    case post.href {
      Some(href) -> #("href", json.string(href))
      None ->
        case post.body {
          Some(body) -> #("body", json.string(body))
          None -> panic as "Invalid state"
        }
    },
    #("username", json.string(post.username)),
    #("original_creator", json.bool(post.original_creator)),
    #("likes", json.int(post.likes)),
    #("user_like_post", json.bool(post.user_like_post)),
    #("comments_count", json.int(post.comments_count)),
    #("comments", post_comment.post_comments_to_json(post.comments)),
    #("tags", json.array(post.tags, fn(tag) { json.string(tag) })),
    #("created_at", json.int(post.created_at)),
  ])
}

pub fn get_posts(req: Request) -> Result(List(Post), String) {
  use post_rows <- result.try(
    sql.get_posts(db.get_connection())
    |> result.replace_error("Problem getting posts from database"),
  )

  Ok(post_rows_to_post(
    req,
    list.map(post_rows.rows, fn(row) {
      ListPostsDBRow(
        post_id: row.id,
        post_title: row.title,
        post_href: row.href,
        post_body: row.body,
        user_username: case row.username {
          Some(a) -> a
          None -> panic
        },
        post_original_creator: row.original_creator,
        like_count: row.like_count,
        comment_count: row.comment_count,
        created_at: row.created_at |> float.round,
      )
    }),
    False,
  ))
}

pub fn get_post_by_id(req: Request, post_id: Int) -> Result(Post, String) {
  use post_rows <- result.try(
    sql.get_post_by_id(db.get_connection(), post_id)
    |> result.replace_error("Problem getting post by id from database"),
  )

  post_rows_to_post(
    req,
    list.map(post_rows.rows, fn(row) {
      ListPostsDBRow(
        post_id: row.id,
        post_title: row.title,
        post_href: row.href,
        post_body: row.body,
        user_username: case row.username {
          Some(a) -> a
          None -> panic
        },
        post_original_creator: row.original_creator,
        like_count: row.like_count,
        comment_count: row.comment_count,
        created_at: row.created_at |> float.round,
      )
    }),
    False,
  )
  |> list.first
  |> result.replace_error("No post found when getting post by id")
}

pub fn get_latest_post_by_user(
  req: Request,
  user_id: Int,
) -> Result(Post, String) {
  use post_rows <- result.try(
    sql.get_latest_post_by_user_id(db.get_connection(), user_id)
    |> result.replace_error("Failed gettings posts to database in latest_posts"),
  )

  post_rows_to_post(
    req,
    list.map(post_rows.rows, fn(row) {
      ListPostsDBRow(
        post_id: row.id,
        post_title: row.title,
        post_href: row.href,
        post_body: row.body,
        user_username: case row.username {
          Some(a) -> a
          None -> panic
        },
        post_original_creator: row.original_creator,
        like_count: row.like_count,
        comment_count: row.comment_count,
        created_at: row.created_at |> float.round,
      )
    }),
    False,
  )
  |> list.first
  |> result.replace_error("No post found in latest_posts")
}
