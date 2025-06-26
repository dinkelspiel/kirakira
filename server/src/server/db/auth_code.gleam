import gleam/list
import gleam/result
import server/db
import server/sql

pub type AuthCode {
  AuthCode(id: Int, token: String, user_id: Int, used: Bool)
}

pub fn get_auth_code(token: String) {
  use db <- db.get_connection()

  let auth_code_result = sql.get_auth_code_by_token(token) |> db.query(db, _)

  use auth_code <- result.try(
    auth_code_result
    |> result.replace_error("Problem getting auth_code by token from db"),
  )

  case list.first(auth_code.rows) {
    Ok(auth_code) ->
      Ok(AuthCode(
        id: auth_code.id,
        token: auth_code.token,
        user_id: auth_code.creator_id,
        used: auth_code.used == 1,
      ))
    Error(_) -> Error("No auth code could be found with same token")
  }
}

pub fn mark_auth_code_as_used(auth_code: AuthCode) {
  use db <- db.get_connection()

  sql.update_auth_code_as_used(auth_code.id)
  |> db.exec(db, _)
  |> result.replace_error("Problem with marking auth code as used")
}

pub fn create_auth_code(token: String, user_id: Int) {
  use db <- db.get_connection()

  case sql.create_auth_code(token, user_id) |> db.exec(db, _) {
    Ok(_) -> Ok(Nil)
    Error(_) -> Error("Error creating auth_code")
  }
}
