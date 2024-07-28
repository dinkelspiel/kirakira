import backend/db
import backend/response
import backend/web
import cake
import cake/dialect/mysql_dialect
import cake/insert as i
import cake/join as j
import cake/param
import cake/select as s
import cake/update as u
import cake/where as w
import gleam/bit_array
import gleam/dynamic
import gleam/http.{Get, Post}
import gleam/int
import gleam/json
import gleam/list
import gleam/option.{Some}
import gleam/result
import gleam/string_builder
import gmysql
import wisp.{type Request, type Response}

pub type AuthCode {
  AuthCode(id: Int, token: String, user_id: Int, used: Bool)
}

pub fn get_auth_code(auth_code: String) {
  let auth_code_result = case
    s.new()
    |> s.selects([
      s.col("auth_code.id"),
      s.col("auth_code.token"),
      s.col("auth_code.creator_id"),
      s.col("auth_code.used"),
    ])
    |> s.from_table("auth_code")
    |> s.where(w.eq(w.col("auth_code.token"), w.string(auth_code)))
    |> s.to_query
    |> db.execute_read(
      [gmysql.to_param(auth_code)],
      dynamic.tuple4(dynamic.int, dynamic.string, dynamic.int, dynamic.int),
    )
  {
    Ok(auth_codes) -> Ok(list.first(auth_codes))
    Error(_) -> Error("Problem getting auth code")
  }

  use auth_code <- result.try(auth_code_result)

  case auth_code {
    Ok(auth_code) ->
      Ok(
        AuthCode(
          id: auth_code.0,
          token: auth_code.1,
          user_id: auth_code.2,
          used: {
            case auth_code.3 {
              val if val == 0 -> False
              _ -> True
            }
          },
        ),
      )
    Error(_) -> Error("No auth code could be found with same token")
  }
}

pub fn mark_auth_code_as_used(auth_code: AuthCode) {
  u.new()
  |> u.table("auth_code")
  |> u.sets(["used" |> u.set_true])
  |> u.where(w.eq(w.col("auth_code.id"), w.int(auth_code.id)))
  |> u.to_query
  |> db.execute_write([gmysql.to_param(1), gmysql.to_param(auth_code.id)])
  |> result.replace_error("Problem with marking auth code as used")
}

pub fn create_auth_code(token: String, user_id: Int) {
  let result =
    [i.row([i.string(token), i.int(user_id)])]
    |> i.from_values(table_name: "auth_code", columns: ["token", "creator_id"])
    |> i.to_query
    |> db.execute_write([gmysql.to_param(token), gmysql.to_param(user_id)])

  case result {
    Ok(_) -> Ok(Nil)
    Error(_) -> Error("Error creating auth_code")
  }
}
