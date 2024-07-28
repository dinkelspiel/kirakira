import backend/db.{list_to_tuple}
import backend/response
import backend/web
import cake
import cake/dialect/mysql_dialect
import cake/join as j
import cake/param
import cake/select as s
import cake/where as w
import decode
import gleam/bit_array
import gleam/dynamic
import gleam/http.{Get, Post}
import gleam/int
import gleam/json
import gleam/list
import gleam/option.{type Option, Some}
import gleam/result
import gleam/string_builder
import gmysql
import wisp.{type Request, type Response}

pub type User {
  User(
    id: Int,
    username: String,
    email: String,
    password: String,
    invited_by: Option(Int),
  )
}

fn get_user_base_query() {
  s.new()
  |> s.selects([
    s.col("user.id"),
    s.col("user.username"),
    s.col("user.email"),
    s.col("user.password"),
    s.col("user.invited_by"),
  ])
  |> s.from_table("user")
}

fn user_db_decoder() {
  fn(data) {
    decode.into({
      use id <- decode.parameter
      use username <- decode.parameter
      use email <- decode.parameter
      use password <- decode.parameter
      use invited_by <- decode.parameter

      User(id, username, email, password, invited_by)
    })
    |> decode.field(0, decode.int)
    |> decode.field(1, decode.string)
    |> decode.field(2, decode.string)
    |> decode.field(3, decode.string)
    |> decode.field(4, decode.optional(decode.int))
    |> decode.from(data |> list_to_tuple)
  }
}

pub fn get_user_by_username(username: String) -> Result(User, String) {
  let user = case
    get_user_base_query()
    |> s.where(w.eq(w.col("user.username"), w.string(username)))
    |> s.to_query
    |> db.execute_read([gmysql.to_param(username)], user_db_decoder())
  {
    Ok(users) -> Ok(list.first(users))
    Error(_) -> Error("Problem getting user by username")
  }

  use user_result <- result.try(user)
  case user_result {
    Ok(user) -> Ok(user)
    Error(_) -> Error("No user found when getting user by username")
  }
}

pub fn get_user_by_email(email: String) -> Result(User, String) {
  let user = case
    get_user_base_query()
    |> s.where(w.eq(w.col("user.email"), w.string(email)))
    |> s.to_query
    |> db.execute_read([gmysql.to_param(email)], user_db_decoder())
  {
    Ok(users) -> Ok(list.first(users))
    Error(_) -> Error("Problem getting user by email")
  }

  use user_result <- result.try(user)
  case user_result {
    Ok(user) -> Ok(user)
    Error(_) -> Error("No user found when getting user by username")
  }
}

pub fn get_user_by_id(user_id: Int) -> Result(User, String) {
  let user = case
    get_user_base_query()
    |> s.where(w.eq(w.col("user.id"), w.int(user_id)))
    |> s.to_query
    |> db.execute_read([gmysql.to_param(user_id)], user_db_decoder())
  {
    Ok(users) -> Ok(list.first(users))
    Error(_) -> Error("Problem getting user by id")
  }

  use user_result <- result.try(user)
  case user_result {
    Ok(user) -> Ok(user)
    Error(_) -> Error("No user found when getting user by id")
  }
}

type UserAdmin {
  UserAdmin(id: Int, user_id: Int)
}

pub fn is_user_admin(user_id: Int) -> Bool {
  let result =
    s.new()
    |> s.selects([s.col("user_admin.id"), s.col("user_admin.user_id")])
    |> s.from_table("user_admin")
    |> s.where(w.eq(w.col("user_admin.user_id"), w.int(user_id)))
    |> s.to_query
    |> db.execute_read([gmysql.to_param(user_id)], fn(data) {
      decode.into({
        use id <- decode.parameter
        use user_id <- decode.parameter

        UserAdmin(id, user_id)
      })
      |> decode.field(0, decode.int)
      |> decode.field(1, decode.int)
      |> decode.from(data)
    })

  case result {
    Ok(result) ->
      case list.first(result) {
        Ok(_) -> True
        Error(_) -> False
      }
    Error(_) -> False
  }
}
