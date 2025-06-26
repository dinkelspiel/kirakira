import gleam/http.{Post}
import gleam/list
import gleam/result
import server/db
import server/db/enums
import server/db/user_session
import server/sql
import wisp.{type Request}

pub type UserLike {
  UserLike(
    id: Int,
    user_id: Int,
    column_id: Int,
    column: UserLikeColumn,
    status: enums.LikeStatus,
  )
}

pub type UserLikeColumn {
  Post
  PostComment
}

pub fn get_user_likes(user_id: Int, column_id: Int, column: UserLikeColumn) {
  use db <- db.get_connection()

  case column {
    Post -> {
      use user_like_posts <- result.try(
        sql.get_user_post_likes(user_id, column_id)
        |> db.query(db, _)
        |> result.replace_error(
          "Problem getting and decoding user_like_post from db",
        ),
      )

      list.first(user_like_posts.rows)
      |> result.replace_error("No user_like_post found")
      |> result.map(fn(a) {
        UserLike(
          id: a.id,
          user_id:,
          column_id:,
          column:,
          status: enums.decode_like_status(a.status),
        )
      })
    }
    PostComment -> {
      use user_like_post_comments <- result.try(
        sql.get_user_post_comment_likes(user_id, column_id)
        |> db.query(db, _)
        |> result.replace_error(
          "Problem getting and decoding user_like_post_comment from db",
        ),
      )

      list.first(user_like_post_comments.rows)
      |> result.replace_error("No user_like_post_comment found")
      |> result.map(fn(a) {
        UserLike(
          id: a.id,
          user_id:,
          column_id:,
          column:,
          status: enums.decode_like_status(a.status),
        )
      })
    }
  }
}

pub fn set_status_for_user_like(
  user_like_id: Int,
  status: enums.LikeStatus,
  column: UserLikeColumn,
) {
  use db <- db.get_connection()

  case column {
    Post -> {
      case
        sql.update_user_like_post_status(
          status |> enums.like_status_to_dynamic,
          user_like_id,
        )
        |> db.exec(db, _)
      {
        Ok(_) -> Ok(Nil)
        Error(_) -> Error("Problem setting status for user_like_post")
      }
    }
    PostComment -> {
      case
        sql.update_user_like_post_comment_status(
          status |> enums.like_status_to_dynamic,
          user_like_id,
        )
        |> db.exec(db, _)
      {
        Ok(_) -> Ok(Nil)
        Error(_) -> Error("Problem setting status for user_like_post_comment")
      }
    }
  }
}

pub fn create_user_like(user_id: Int, column_id: Int, column: UserLikeColumn) {
  use db <- db.get_connection()

  case column {
    Post ->
      sql.create_user_like_post(
        user_id,
        column_id,
        enums.Like |> enums.like_status_to_dynamic,
      )
      |> db.exec(db, _)
      |> result.replace(Nil)
      |> result.replace_error("Error creating user_like_post")
    PostComment ->
      sql.create_user_like_post_comment(
        user_id,
        column_id,
        enums.Like |> enums.like_status_to_dynamic,
      )
      |> db.exec(db, _)
      |> result.replace(Nil)
      |> result.replace_error("Error creating user_like_post_comment")
  }
}

pub fn get_auth_user_likes(req: Request, column_id: Int, col: UserLikeColumn) {
  let result = {
    use auth_user_id <- result.try(user_session.get_user_id_from_session(req))
    use user_like <- result.try(get_user_likes(auth_user_id, column_id, col))

    case user_like.status {
      enums.Like -> Ok(True)
      enums.Neutral -> Ok(False)
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
        enums.Like -> set_status_for_user_like(user_like.id, enums.Neutral, col)
        enums.Neutral -> set_status_for_user_like(user_like.id, enums.Like, col)
      }
    Error(_) -> create_user_like(user_id, column_id, col)
  }

  Nil
}
