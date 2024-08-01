import cake/insert as i
import cake/select as s
import cake/where as w
import gleam/dynamic
import gleam/io
import gleam/list
import gleam/result
import gmysql
import server/db
import server/generatetoken.{generate_token}
import wisp.{type Request}

pub fn get_user_id_from_session(req: Request) {
  use session_token <- result.try(
    wisp.get_cookie(req, "kk_session_token", wisp.PlainText)
    |> result.replace_error("No session cookie found"),
  )

  let session_token = case
    s.new()
    |> s.selects([s.col("user_session.id"), s.col("user_session.user_id")])
    |> s.from_table("user_session")
    |> s.where(w.eq(w.col("user_session.token"), w.string(session_token)))
    |> s.to_query
    |> db.execute_read(
      [gmysql.to_param(session_token)],
      dynamic.tuple2(dynamic.int, dynamic.int),
    )
  {
    Ok(users) -> Ok(list.first(users))
    Error(err) -> {
      io.debug(err)
      Error("Problem getting user_session by token")
    }
  }

  use user_id_result <- result.try(session_token)
  case user_id_result {
    Ok(id) -> Ok(id.1)
    Error(_) ->
      Error("No user_session found when getting user_session by token")
  }
}

pub fn create_user_session(user_id: Int) {
  let token = generate_token(64)

  let result =
    [i.row([i.int(user_id), i.string(token)])]
    |> i.from_values(table_name: "user_session", columns: ["user_id", "token"])
    |> i.to_query
    |> db.execute_write([gmysql.to_param(user_id), gmysql.to_param(token)])

  case result {
    Ok(_) -> Ok(token)
    Error(_) -> Error("Creating user session")
  }
}
