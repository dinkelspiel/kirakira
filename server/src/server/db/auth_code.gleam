import gleam/list
import gleam/result
import server/db
import squirrels/sql

pub type AuthCode {
  AuthCode(id: Int, token: String, user_id: Int, used: Bool)
}

pub fn get_auth_code(token: String) {
  use db_connection <- db.get_connection()

  let auth_code_result = sql.get_auth_code_by_token(db_connection, token)

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
        used: auth_code.used,
      ))
    Error(_) -> Error("No auth code could be found with same token")
  }
}

pub fn mark_auth_code_as_used(auth_code: AuthCode) {
  use db_connection <- db.get_connection()

  sql.update_auth_code_as_used(db_connection, auth_code.id)
  |> result.replace_error("Problem with marking auth code as used")
}

pub fn create_auth_code(token: String, user_id: Int) {
  use db_connection <- db.get_connection()

  case sql.create_auth_code(db_connection, token, user_id) {
    Ok(_) -> Ok(Nil)
    Error(_) -> Error("Error creating auth_code")
  }
}
