import gleam/list
import gleam/result
import server/db
import server/generatetoken.{generate_token}
import server/sql
import shork
import wisp.{type Request}

pub fn get_user_id_from_session(req: Request) {
  use session_token <- result.try(
    wisp.get_cookie(req, "kk_session_token", wisp.PlainText)
    |> result.replace_error("No session cookie found"),
  )

  use db <- db.get_connection()

  let session_token = case
    sql.get_user_id_from_session(session_token) |> db.query(db, _)
  {
    Ok(shork.Returned(_, row)) -> Ok(list.first(row))
    Error(_) -> Error("Problem getting user_session by token")
  }

  use user_id_result <- result.try(session_token)
  case user_id_result {
    Ok(id) -> Ok(id.user_id)
    Error(_) ->
      Error("No user_session found when getting user_session by token")
  }
}

pub fn create_user_session(user_id: Int) {
  let token = generate_token(64)

  use db <- db.get_connection()

  case sql.create_user_session(user_id, token) |> db.exec(db, _) {
    Ok(_) -> Ok(token)
    Error(_) -> Error("Creating user session")
  }
}
