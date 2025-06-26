import beecrypt
import gleam/list
import gleam/option.{type Option}
import gleam/result
import server/db
import server/sql

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
  use db <- db.get_connection()

  use returned <- result.try(
    sql.get_user_by_username(username)
    |> db.query(db, _)
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
  use db <- db.get_connection()

  use returned <- result.try(
    sql.get_user_by_email(email)
    |> db.query(db, _)
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
  use db <- db.get_connection()

  use returned <- result.try(
    sql.get_user_by_id(user_id)
    |> db.query(db, _)
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
  case db.get_connection_raw() {
    Ok(db) ->
      case sql.get_user_is_admin(user_id) |> db.query(db, _) {
        Ok(returned) ->
          case list.first(returned.rows) {
            Ok(_) -> True
            Error(_) -> False
          }
        Error(_) -> False
      }
    Error(_) -> False
  }
}

/// Takes plain text password
pub fn set_password_for_user(user_id: Int, password: String) {
  use db <- db.get_connection()

  sql.update_user_password(beecrypt.hash(password), user_id)
  |> db.exec(db, _)
  |> result.replace(Nil)
  |> result.replace_error("Problem with updating user password")
}
