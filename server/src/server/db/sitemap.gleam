import cake/fragment as f
import cake/select as s
import cake/where as w
import decode
import gleam/list
import gleam/result
import gmysql
import server/db
import server/db/post

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
  let assert Ok(posts) =
    post.get_posts_query()
    |> s.limit(99_999)
    |> post.run_post_query([])

  list.map(posts, fn(p) {
    PostSitemap(
      id: p.post_id,
      title: p.post_title,
      likes: p.like_count,
      tags: case post.get_tags_for_post(p.post_id) {
        Ok(tags) -> tags
        Error(_) -> panic as "Problem getting tags"
      },
      username: p.user_username,
      created_at: p.created_at,
      comments_at: get_comments_for_sitemap(p.post_id),
    )
  })
}

fn get_comments_for_sitemap(post_id: Int) {
  s.new()
  |> s.selects([
    s.col("post_comment.id"),
    s.fragment(f.literal(
      "UNIX_TIMESTAMP(post_comment.created_at) AS created_at",
    )),
  ])
  |> s.from_table("post_comment")
  |> s.where(w.eq(w.col("post_comment.post_id"), w.int(post_id)))
  |> s.order_by_desc("post_comment.created_at")
  |> s.to_query
  |> db.execute_read([gmysql.to_param(post_id)], fn(data) {
    decode.into({
      use _ <- decode.parameter
      use created_at <- decode.parameter

      created_at
    })
    |> decode.field(0, decode.int)
    |> decode.field(1, decode.int)
    |> decode.from(data |> db.list_to_tuple)
  })
  |> result.unwrap([])
}
