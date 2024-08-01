import birl
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string_builder.{type StringBuilder}
import wisp.{type Response}
import xmleam/xml_builder.{
  type BuilderError, type XmlBuilder, ContentsEmpty, block_tag, new, tag,
}

import server/db/sitemap.{type PostSitemap, get_post_sitemap}

fn new_sitemap(map: StringBuilder) -> XmlBuilder {
  string_builder.new()
  |> string_builder.append(
    "<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">\n",
  )
  |> string_builder.append_builder(map)
  |> string_builder.append("</urlset>\n")
  |> Ok
}

pub fn sitemap_xml() -> Response {
  let posts: List(PostSitemap) = get_post_sitemap()

  let post_map: Result(StringBuilder, BuilderError) = {
    case
      list.map(posts, fn(post) {
        let post_updated_at: Int =
          post.comments_at
          |> list.reduce(fn(acc, x) {
            case acc < x {
              True -> x
              False -> acc
            }
          })
          |> result.unwrap(post.created_at)

        new()
        |> block_tag("url", {
          new()
          |> tag(
            "loc",
            "https://kirakira.keii.dev/post/" <> int.to_string(post.id),
          )
          |> tag(
            "lastmod",
            post_updated_at
              |> birl.from_unix
              |> birl.to_iso8601,
          )
          |> tag("changefreq", case
            // if the post was updated less than a day ago, set it to daily
            { { { birl.now() |> birl.to_unix() } - post_updated_at } > 86_400 }
          {
            False -> "daily"
            True -> "weekly"
          })
          |> tag("priority", {
            let inactive: Bool =
              { { birl.now() |> birl.to_unix() } - post_updated_at } > 864_000
            case inactive {
              True -> "0.5"
              False -> "0.7"
            }
          })
        })
      })
      |> list.reduce(fn(acc, x) {
        case acc {
          Ok(acc) ->
            case x {
              Ok(x) -> Ok(acc |> string_builder.append_builder(x))
              Error(_) -> Error(ContentsEmpty)
            }
          Error(_) -> Error(ContentsEmpty)
        }
      })
    {
      Ok(post_map) -> post_map
      Error(_) -> Error(ContentsEmpty)
    }
  }

  let base_map =
    new()
    |> block_tag("url", {
      new()
      |> tag("loc", "https://kirakira.keii.dev")
      |> tag("changefreq", "daily")
      |> tag("priority", "1.0")
    })

  let full_map: Result(StringBuilder, BuilderError) = case base_map {
    Ok(base_map) ->
      case post_map {
        Ok(post_map) -> Ok(base_map |> string_builder.append_builder(post_map))
        Error(_) -> Error(ContentsEmpty)
      }
    Error(_) -> Error(ContentsEmpty)
  }

  case full_map {
    Ok(full_map) -> {
      case full_map |> new_sitemap {
        Ok(sitemap) ->
          wisp.response(200)
          |> wisp.set_header("Content-Type", "text/xml")
          |> wisp.string_builder_body(sitemap)
        Error(_) -> wisp.response(500)
      }
    }
    Error(_) -> wisp.response(500)
  }
}
