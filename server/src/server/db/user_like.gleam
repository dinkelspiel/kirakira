import server/db
import server/db/user_session
import cake/insert as i
import cake/select as s
import cake/update as u
import cake/where as w
import decode
import gleam/http.{Post}
import gleam/list
import gleam/result
import gmysql
import wisp.{type Request}

pub type UserLike {
  UserLike(
    id: Int,
    user_id: Int,
    column_id: Int,
    column: UserLikeColumn,
    status: UserLikeStatus,
  )
}

pub type UserLikeColumn {
  Post
  PostComment
}

pub type UserLikeStatus {
  Like
  Neutral
}

fn col_to_string(col: UserLikeColumn) {
  case col {
    Post -> "post"
    PostComment -> "post_comment"
  }
}

pub fn get_user_likes(user_id: Int, column_id: Int, col: UserLikeColumn) {
  use user_like_posts <- result.try(
    s.new()
    |> s.selects([
      s.col("user_like_" <> col_to_string(col) <> ".id"),
      s.col("user_like_" <> col_to_string(col) <> ".user_id"),
      s.col(
        "user_like_" <> col_to_string(col) <> "." <> col_to_string(col) <> "_id",
      ),
      s.col("user_like_" <> col_to_string(col) <> ".status"),
    ])
    |> s.from_table("user_like_" <> col_to_string(col) <> "")
    |> s.where(
      w.and([
        w.eq(
          w.col("user_like_" <> col_to_string(col) <> ".user_id"),
          w.int(user_id),
        ),
        w.eq(
          w.col(
            "user_like_"
            <> col_to_string(col)
            <> "."
            <> col_to_string(col)
            <> "_id",
          ),
          w.int(column_id),
        ),
      ]),
    )
    |> s.to_query
    |> db.execute_read(
      [gmysql.to_param(user_id), gmysql.to_param(column_id)],
      fn(data) {
        decode.into({
          use id <- decode.parameter
          use user_id <- decode.parameter
          use column_id <- decode.parameter
          use status <- decode.parameter

          UserLike(id, user_id, column_id, column: col, status: case status {
            "like" -> Like
            _ -> Neutral
          })
        })
        |> decode.field(0, decode.int)
        |> decode.field(1, decode.int)
        |> decode.field(2, decode.int)
        |> decode.field(3, decode.string)
        |> decode.from(data |> db.list_to_tuple)
      },
    )
    |> result.replace_error(
      "Problem getting and decoding user_like_post from db",
    ),
  )

  list.first(user_like_posts) |> result.replace_error("No user_like_post found")
}

pub fn set_status_for_user_like(
  user_like_id: Int,
  status: UserLikeStatus,
  col: UserLikeColumn,
) {
  case
    u.new()
    |> u.table("user_like_" <> col_to_string(col))
    |> u.sets([
      u.set_string("status", case status {
        Like -> "like"
        Neutral -> "neutral"
      }),
    ])
    |> u.where(w.eq(
      w.col("user_like_" <> col_to_string(col) <> ".id"),
      w.int(user_like_id),
    ))
    |> u.to_query
    |> db.execute_write([
      gmysql.to_param(case status {
        Like -> "like"
        Neutral -> "neutral"
      }),
      gmysql.to_param(user_like_id),
    ])
  {
    Ok(_) -> Ok(Nil)
    Error(_) ->
      Error("Problem setting status for user_like_" <> col_to_string(col))
  }
}

pub fn create_user_like(user_id: Int, column_id: Int, col: UserLikeColumn) {
  let result =
    [i.row([i.int(user_id), i.int(column_id), i.string("like")])]
    |> i.from_values(table_name: "user_like_" <> col_to_string(col), columns: [
      "user_id",
      col_to_string(col) <> "_id",
      "status",
    ])
    |> i.to_query
    |> db.execute_write([
      gmysql.to_param(user_id),
      gmysql.to_param(column_id),
      gmysql.to_param("like"),
    ])

  case result {
    Ok(_) -> Ok(Nil)
    Error(_) -> Error("Creating user_like_" <> col_to_string(col))
  }
}

pub fn get_auth_user_likes(req: Request, column_id: Int, col: UserLikeColumn) {
  let result = {
    use auth_user_id <- result.try(user_session.get_user_id_from_session(req))
    use user_like <- result.try(get_user_likes(auth_user_id, column_id, col))

    case user_like.status {
      Like -> Ok(True)
      Neutral -> Ok(False)
    }
  }

  case result {
    Ok(val) -> val
    Error(_) -> False
  }
}

pub fn toggle_like(user_id: Int, column_id: Int, col: UserLikeColumn) {
  let _ = case get_user_likes(user_id, column_id, col) {
    Ok(user_like) ->
      case user_like.status {
        Like -> set_status_for_user_like(user_like.id, Neutral, col)
        Neutral -> set_status_for_user_like(user_like.id, Like, col)
      }
    Error(_) -> create_user_like(user_id, column_id, col)
  }

  Nil
}
