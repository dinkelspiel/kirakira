import cake/insert as i
import cake/select as s
import cake/update as u
import cake/where as w
import decode
import gleam/list
import gleam/result
import gmysql
import server/db
import server/db/user
import server/generatetoken

/// Returns the forgot password token
pub fn create_forgot_password(email: String) {
  use user <- result.try(user.get_user_by_email(email))

  let token = generatetoken.generate_token(64)

  let result =
    [i.row([i.int(user.id), i.string(token)])]
    |> i.from_values(table_name: "user_forgot_password", columns: [
      "user_id", "token",
    ])
    |> i.to_query
    |> db.execute_write([gmysql.to_param(user.id), gmysql.to_param(token)])

  case result {
    Ok(_) -> Ok(token)
    Error(_) -> Error("Problem inserting forgot password to db")
  }
}

type IdUserId {
  IdUserId(id: Int, user_id: Int)
}

pub fn get_user_by_forgot_password(token: String) {
  let forgot_passwords =
    s.new()
    |> s.selects([
      s.col("user_forgot_password.id"),
      s.col("user_forgot_password.user_id"),
    ])
    |> s.from_table("user_forgot_password")
    |> s.where(
      w.and([
        w.eq(w.col("user_forgot_password.token"), w.string(token)),
        w.eq(w.col("user_forgot_password.used"), w.int(0)),
      ]),
    )
    |> s.to_query
    |> db.execute_read([gmysql.to_param(token), gmysql.to_param(0)], fn(data) {
      decode.into({
        use id <- decode.parameter
        use user_id <- decode.parameter

        IdUserId(id, user_id)
      })
      |> decode.field(0, decode.int)
      |> decode.field(1, decode.int)
      |> decode.from(data |> db.list_to_tuple)
    })

  case forgot_passwords {
    Ok(forgot_passwords) ->
      case list.first(forgot_passwords) {
        Ok(forgot_password) -> user.get_user_by_id(forgot_password.user_id)
        Error(_) -> Error("No unused user_forgot_password found")
      }
    Error(_) -> Error("Getting user_forgot_password from db")
  }
}

// Takes in token
pub fn mark_forgot_password_as_used(token: String) {
  u.new()
  |> u.table("user_forgot_password")
  |> u.sets(["used" |> u.set_true])
  |> u.where(w.eq(w.col("user_forgot_password.token"), w.string(token)))
  |> u.to_query
  |> db.execute_write([gmysql.to_param(1), gmysql.to_param(token)])
  |> result.replace_error("Problem with marking forgot password as used")
}
