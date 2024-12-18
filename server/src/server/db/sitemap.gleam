import gleam/float
import gleam/list
import gleam/option.{None, Some}
import server/db
import server/db/post
import squirrels/sql

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
  let assert Ok(posts) = sql.get_posts_unlimited(db.get_connection())

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
      created_at: p.created_at |> float.round,
      comments_at: get_comments_for_sitemap(p.id)
        |> list.map(fn(a) { a.created_at |> float.round }),
    )
  })
}

fn get_comments_for_sitemap(post_id: Int) {
  case sql.get_comments_for_sitemap(db.get_connection(), post_id) {
    Ok(result) -> result.rows
    Error(_) -> []
  }
}
