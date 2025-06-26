import gleam/float
import gleam/list
import gleam/option.{None, Some}
import server/db
import server/db/post
import server/sql

pub type PostSitemap {
  PostSitemap(
    id: Int,
    title: String,
    likes: Int,
    comments_at: List(Int),
    tags: List(String),
    username: String,
    created_at: Int,
  )
}

pub fn get_post_sitemap() {
  let assert Ok(db) = db.get_connection_raw()

  let assert Ok(posts) = sql.get_posts_unlimited() |> db.query(db, _)

  list.map(posts.rows, fn(p) {
    PostSitemap(
      id: p.id,
      title: p.title,
      likes: p.like_count,
      tags: case post.get_tags_for_post(p.id) {
        Ok(tags) -> tags
        Error(_) -> panic as "Problem getting tags"
      },
      username: case p.username {
        Some(a) -> a
        None -> panic
      },
      created_at: p.created_at,
      comments_at: get_comments_for_sitemap(p.id)
        |> list.map(fn(a) { a.created_at }),
    )
  })
}

fn get_comments_for_sitemap(post_id: Int) {
  let assert Ok(db) = db.get_connection_raw()

  case sql.get_comments_for_sitemap(post_id) |> db.query(db, _) {
    Ok(result) -> result.rows
    Error(_) -> []
  }
}
