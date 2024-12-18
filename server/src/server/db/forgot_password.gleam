import gleam/list
import gleam/result
import server/db
import server/db/user
import server/generatetoken
import squirrels/sql

/// Returns the forgot password token
pub fn create_forgot_password(email: String) {
  use user <- result.try(user.get_user_by_email(email))

  let token = generatetoken.generate_token(64)

  let result = sql.create_forgot_password(db.get_connection(), user.id, token)

  case result {
    Ok(_) -> Ok(token)
    Error(_) -> Error("Problem inserting forgot password to db")
  }
}

pub fn get_user_by_forgot_password(token: String) {
  let forgot_passwords =
    sql.get_user_by_forgot_password(db.get_connection(), token)

  case forgot_passwords {
    Ok(forgot_passwords) ->
      case list.first(forgot_passwords.rows) {
        Ok(forgot_password) -> user.get_user_by_id(forgot_password.user_id)
        Error(_) -> Error("No unused user_forgot_password found")
      }
    Error(_) -> Error("Getting user_forgot_password from db")
  }
}

// Takes in token
pub fn mark_forgot_password_as_used(token: String) {
  sql.update_forgot_password_as_used(db.get_connection(), token)
  |> result.replace(Nil)
  |> result.replace_error("Problem with marking forgot password as used")
}
