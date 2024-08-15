import birl
import gleam/int
import gleam/list
import gleam/result
import server/db/sitemap as db
import webls/sitemap
import wisp.{type Response}

pub fn sitemap_xml() -> Response {
  let posts: List(db.PostSitemap) = db.get_post_sitemap()

  let post_pages =
    posts
    |> list.map(fn(post) {
      let updated_at: Int =
        post.comments_at
        |> list.reduce(fn(acc, x) {
          case acc < x {
            True -> x
            False -> acc
          }
        })
        |> result.unwrap(post.created_at)

      sitemap.item("https://kirakira.keii.dev/post/" <> int.to_string(post.id))
      |> sitemap.with_item_last_modified(updated_at |> birl.from_unix)
      |> sitemap.with_item_frequency(case
        // if the post was updated less than a day ago, set it to daily
        { { { birl.now() |> birl.to_unix() } - updated_at } > 86_400 }
      {
        False -> sitemap.Daily
        True -> sitemap.Weekly
      })
      |> sitemap.with_item_priority(case
        // if the post was updated more than ten days ago, set it to inactive
        { { birl.now() |> birl.to_unix() } - updated_at } > 864_000
      {
        True -> 0.5
        False -> 0.7
      })
    })

  let site_last_modified: birl.Time =
    posts
    |> list.map(fn(post) {
      post.comments_at
      |> list.reduce(fn(acc, x) {
        case acc < x {
          True -> x
          False -> acc
        }
      })
      |> result.unwrap(post.created_at)
    })
    |> list.reduce(fn(acc, x) {
      case acc < x {
        True -> x
        False -> acc
      }
    })
    |> result.unwrap(birl.now() |> birl.to_unix)
    |> birl.from_unix

  let sitemap =
    sitemap.sitemap("https://kirakira.keii.dev/sitemap.xml")
    |> sitemap.with_sitemap_last_modified(site_last_modified)
    |> sitemap.with_sitemap_items([
      sitemap.item("https://kirakira.keii.dev")
        |> sitemap.with_item_last_modified(site_last_modified)
        |> sitemap.with_item_frequency(sitemap.Daily)
        |> sitemap.with_item_priority(1.0),
      sitemap.item("https://kirakira.keii.dev/auth/login")
        |> sitemap.with_item_priority(0.8),
      ..post_pages
    ])

  wisp.response(200)
  |> wisp.set_header("Content-Type", "text/xml")
  |> wisp.string_body(sitemap |> sitemap.to_string)
}
