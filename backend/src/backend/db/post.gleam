import backend/db.{list_to_tuple}
import backend/db/post_comment
import backend/db/user_like
import cake/fragment as f
import cake/join as j
import cake/select.{type Select}
import cake/select as s
import cake/where as w
import decode
import gleam/dynamic.{type Dynamic}
import gleam/int
import gleam/json.{type Json}
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gmysql
import shared.{type Post, type PostComment, Post, PostComment}
import wisp.{type Request}

pub type ListPostsDBRow {
  ListPostsDBRow(
    post_id: Int,
    post_title: String,
    post_href: Option(String),
    post_body: Option(String),
    user_username: String,
    post_original_creator: Int,
    like_count: Int,
    comment_count: Int,
    created_at: Int,
  )
}

pub fn get_posts_query() {
  s.new()
  |> s.selects([
    s.alias(s.col("post.id"), "post_id"),
    s.alias(s.col("post.title"), "post_title"),
    s.alias(s.col("post.href"), "post_href"),
    s.alias(s.col("post.body"), "post_body"),
    s.alias(s.col("user.username"), "user_username"),
    s.alias(s.col("post.original_creator"), "post_original_creator"),
    s.fragment(f.literal("COUNT(DISTINCT user_like_post.id) AS like_count")),
    s.fragment(f.literal("COUNT(DISTINCT post_comment.id) AS comment_count")),
    s.fragment(f.literal("UNIX_TIMESTAMP(post.created_at) AS created_at")),
  ])
  |> s.from_table("post")
  |> s.join(j.left(
    with: j.table("user_like_post"),
    on: w.and([
      w.eq(w.col("post.id"), w.col("user_like_post.post_id")),
      w.eq(w.col("user_like_post.status"), w.string("like")),
    ]),
    alias: "user_like_post",
  ))
  |> s.join(j.left(
    with: j.table("post_comment"),
    on: w.eq(w.col("post.id"), w.col("post_comment.post_id")),
    alias: "post_comment",
  ))
  |> s.join(j.left(
    with: j.table("user"),
    on: w.eq(w.col("post.user_id"), w.col("user.id")),
    alias: "user",
  ))
  |> s.group_by("post.id")
  |> s.order_by_desc("post.created_at")
  |> s.limit(25)
}

pub fn run_post_query(select: Select, params: List(gmysql.Param)) {
  s.to_query(select)
  |> db.execute_read(list.append([gmysql.to_param("like")], params), fn(data) {
    decode.into({
      use post_id <- decode.parameter
      use post_title <- decode.parameter
      use post_href <- decode.parameter
      use post_body <- decode.parameter
      use user_username <- decode.parameter
      use post_original_creator <- decode.parameter
      use like_count <- decode.parameter
      use comment_count <- decode.parameter
      use created_at <- decode.parameter

      ListPostsDBRow(
        post_id,
        post_title,
        post_href,
        post_body,
        user_username,
        post_original_creator,
        like_count,
        comment_count,
        created_at,
      )
    })
    |> decode.field(0, decode.int)
    |> decode.field(1, decode.string)
    |> decode.field(2, decode.optional(decode.string))
    |> decode.field(3, decode.optional(decode.string))
    |> decode.field(4, decode.string)
    |> decode.field(5, decode.int)
    |> decode.field(6, decode.int)
    |> decode.field(7, decode.int)
    |> decode.field(8, decode.int)
    |> decode.from(data |> list_to_tuple)
  })
}

fn get_tags_for_post(post_id: Int) {
  let result =
    s.new()
    |> s.selects([s.col("tag.id"), s.col("tag.name")])
    |> s.from_table("post_tag")
    |> s.join(j.left(
      with: j.table("tag"),
      on: w.eq(w.col("tag.id"), w.col("post_tag.tag_id")),
      alias: "tag",
    ))
    |> s.where(w.eq(w.col("post_tag.post_id"), w.int(post_id)))
    |> s.to_query()
    |> db.execute_read(
      [gmysql.to_param(post_id)],
      dynamic.tuple2(dynamic.int, dynamic.string),
    )

  case result {
    Ok(rows) -> Ok(rows |> list.map(fn(a) { a.1 }))
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
      original_creator: row.post_original_creator > 0,
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

pub fn get_post_by_id(req: Request, post_id: Int) -> Result(Post, String) {
  use post_rows <- result.try(
    get_posts_query()
    |> s.where(w.eq(w.col("post.id"), w.int(post_id)))
    |> run_post_query([gmysql.to_param(post_id)])
    |> result.replace_error("Problem getting post by id from database"),
  )

  post_rows_to_post(req, post_rows, False)
  |> list.first
  |> result.replace_error("No post found when getting post by id")
}

pub fn get_latest_post_by_user(
  req: Request,
  user_id: Int,
) -> Result(Post, String) {
  use post_rows <- result.try(
    get_posts_query()
    |> s.limit(1)
    |> s.where(w.eq(w.col("post.user_id"), w.int(user_id)))
    |> run_post_query([gmysql.to_param(user_id)])
    |> result.replace_error("Failed gettings posts to database in latest_posts"),
  )

  post_rows_to_post(req, post_rows, False)
  |> list.first
  |> result.replace_error("No post found in latest_posts")
}
