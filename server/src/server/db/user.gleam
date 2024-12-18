import gleam/list
import gleam/option.{type Option}
import gleam/result
import server/db
import squirrels/sql

pub type User {
  User(
    id: Int,
    username: String,
    email: String,
    password: String,
    invited_by: Option(Int),
  )
}

pub fn get_user_by_username(username: String) -> Result(User, String) {
  use returned <- result.try(
    sql.get_user_by_username(db.get_connection(), username)
    |> result.replace_error("Problem getting user by username"),
  )

  case list.first(returned.rows) {
    Ok(user) ->
      Ok(User(
        id: user.id,
        username: user.username,
        email: user.email,
        password: user.password,
        invited_by: user.invited_by,
      ))
    Error(_) -> Error("No user found when getting user by username")
  }
}

pub fn get_user_by_email(email: String) -> Result(User, String) {
  use returned <- result.try(
    sql.get_user_by_email(db.get_connection(), email)
    |> result.replace_error("Problem getting user by email"),
  )

  case list.first(returned.rows) {
    Ok(user) ->
      Ok(User(
        id: user.id,
        username: user.username,
        email: user.email,
        password: user.password,
        invited_by: user.invited_by,
      ))
    Error(_) -> Error("No user found when getting user by email")
  }
}

pub fn get_user_by_id(user_id: Int) -> Result(User, String) {
  use returned <- result.try(
    sql.get_user_by_id(db.get_connection(), user_id)
    |> result.replace_error("Problem getting user by id"),
  )

  case list.first(returned.rows) {
    Ok(user) ->
      Ok(User(
        id: user.id,
        username: user.username,
        email: user.email,
        password: user.password,
        invited_by: user.invited_by,
      ))
    Error(_) -> Error("No user found when getting user by id")
  }
}

pub fn is_user_admin(user_id: Int) -> Bool {
  case sql.get_user_is_admin(db.get_connection(), user_id) {
    Ok(returned) ->
      case list.first(returned.rows) {
        Ok(_) -> True
        Error(_) -> False
      }
    Error(_) -> False
  }
}

/// Takes plain text password
pub fn set_password_for_user(user_id: Int, password: String) {
  sql.update_user_password(db.get_connection(), user_id, password)
  |> result.replace(Nil)
  |> result.replace_error("Problem with updating user password")
}
