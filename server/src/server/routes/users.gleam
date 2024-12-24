import beecrypt
import gleam/bool
import gleam/dynamic
import gleam/http.{Get, Post}
import gleam/json
import gleam/list
import gleam/regexp
import gleam/result
import gleam/string
import server/db
import server/db/auth_code.{type AuthCode, get_auth_code, mark_auth_code_as_used}
import server/db/user.{get_user_by_username}
import server/db/user_session.{create_user_session}
import squirrels/sql
import wisp.{type Request, type Response}

pub fn users(req: Request) -> Response {
  use body <- wisp.require_json(req)

  case req.method {
    Post -> create_user(req, body)
    _ -> wisp.method_not_allowed([Get, Post])
  }
}

type CreateUser {
  CreateUser(
    username: String,
    email: String,
    password: String,
    auth_code: String,
  )
}

fn decode_create_user(
  json: dynamic.Dynamic,
) -> Result(CreateUser, dynamic.DecodeErrors) {
  let decoder =
    dynamic.decode4(
      CreateUser,
      dynamic.field("username", dynamic.string),
      dynamic.field("email", dynamic.string),
      dynamic.field("password", dynamic.string),
      dynamic.field("auth_code", dynamic.string),
    )
  case decoder(json) {
    Ok(create_user) ->
      Ok(CreateUser(
        username: string.lowercase(create_user.username),
        email: string.lowercase(create_user.email),
        password: beecrypt.hash(create_user.password),
        auth_code: create_user.auth_code,
      ))
    Error(error) -> Error(error)
  }
}

fn does_user_with_same_email_or_username_exist(create_user: CreateUser) {
  use db_connection <- db.get_connection()

  use result <- result.try(
    sql.get_user_by_email_or_username(
      db_connection,
      create_user.email,
      create_user.username,
    )
    |> result.replace_error("User by email or username db call failed"),
  )

  Ok(list.length(result.rows) > 0)
}

fn insert_user_to_db(create_user: CreateUser, auth_code: AuthCode) {
  use db_connection <- db.get_connection()

  sql.create_user(
    db_connection,
    create_user.username,
    create_user.email,
    create_user.password,
    auth_code.user_id,
  )
  |> result.replace_error("Error inserting user to db")
}

fn create_user(req: Request, body: dynamic.Dynamic) {
  let result = {
    use user <- result.try(case decode_create_user(body) {
      Ok(val) -> Ok(val)
      Error(_) -> Error("Invalid body recieved")
    })

    use auth_code <- result.try(get_auth_code(user.auth_code))

    use user_with_same_email_or_username_exists <- result.try(
      does_user_with_same_email_or_username_exist(user),
    )

    use <- bool.guard(
      when: user_with_same_email_or_username_exists,
      return: Error("User with same email or username already exists"),
    )

    use <- bool.guard(
      when: user.username == "" || user.email == "",
      return: Error("Username or email can't be empty"),
    )

    use <- bool.guard(
      when: string.length(user.password) < 8,
      return: Error("Password must be more than 8 characters"),
    )

    use <- bool.guard(
      when: {
        let assert Ok(re) =
          regexp.from_string(
            "(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9]))\\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])",
          )
        !regexp.check(with: re, content: user.email)
      },
      return: Error("Invalid email address"),
    )

    use _ <- result.try(case insert_user_to_db(user, auth_code) {
      Ok(_) -> Ok(Nil)
      Error(_) -> Error("Problem creating user")
    })

    use _ <- result.try(mark_auth_code_as_used(auth_code))

    use inserted_user <- result.try(get_user_by_username(user.username))

    use session_token <- result.try(create_user_session(inserted_user.id))

    Ok(session_token)
  }

  case result {
    Ok(session_token) ->
      wisp.json_response(
        json.object([#("message", json.string("Created account"))])
          |> json.to_string_tree,
        201,
      )
      |> wisp.set_cookie(
        req,
        "kk_session_token",
        session_token,
        wisp.PlainText,
        60 * 60 * 24 * 1000,
      )
    Error(error) ->
      wisp.json_response(
        json.object([#("error", json.string(error))])
          |> json.to_string_tree,
        200,
      )
  }
}
