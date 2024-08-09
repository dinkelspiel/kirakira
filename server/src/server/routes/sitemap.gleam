import birl
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import server/db/sitemap.{type PostSitemap, get_post_sitemap}
import webls/sitemap.{Sitemap, SitemapItem} as webls_sitemap
import wisp.{type Response}

pub fn sitemap_xml() -> Response {
  let posts: List(PostSitemap) = get_post_sitemap()

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

      SitemapItem(
        loc: "https://kirakira.keii.dev/post/" <> int.to_string(post.id),
        last_modified: Some(
          updated_at
          |> birl.from_unix,
        ),
        change_frequency: Some(case
          // if the post was updated less than a day ago, set it to daily
          { { { birl.now() |> birl.to_unix() } - updated_at } > 86_400 }
        {
          False -> webls_sitemap.Daily
          True -> webls_sitemap.Weekly
        }),
        priority: Some(case
          // if the post was updated more than ten days ago, set it to inactive
          { { birl.now() |> birl.to_unix() } - updated_at } > 864_000
        {
          True -> 0.5
          False -> 0.7
        }),
      )
    })

  let sitemap =
    Sitemap(
      url: "https://kirakira.keii.dev",
      last_modified: Some(birl.now()),
      items: [
        // the homepage feed
        SitemapItem(
          loc: "https://kirakira.keii.dev",
          last_modified: Some(
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
            |> birl.from_unix,
          ),
          change_frequency: Some(webls_sitemap.Daily),
          priority: Some(1.0),
        ),
        SitemapItem(
          loc: "https://kirakira.keii.dev/auth/login",
          last_modified: None,
          change_frequency: None,
          priority: None,
        ),
        ..post_pages
      ],
    )

  wisp.response(200)
  |> wisp.set_header("Content-Type", "text/xml")
  |> wisp.string_body(sitemap |> webls_sitemap.to_string)
}
