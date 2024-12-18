import gleam/dynamic
import gleam/list
import gleam/result
import gmysql
import server/db
import squirrels

pub type AuthCode {
  AuthCode(id: Int, token: String, user_id: Int, used: Bool)
}

pub fn get_auth_code(auth_code: String) {
  // let auth_code_result =

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
