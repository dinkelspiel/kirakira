import decode
import gleam/option.{type Option}
import gleam/pgo

/// A row you get from running the `get_user_by_username` query
/// defined in `./src/squirrels/sql/get_user_by_username.sql`.
///
/// > 🐿️ This type definition was generated automatically using v1.7.1 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetUserByUsernameRow {
  GetUserByUsernameRow(
    id: Int,
    username: String,
    email: String,
    password: String,
    invited_by: Option(Int),
  )
}

/// Runs the `get_user_by_username` query
/// defined in `./src/squirrels/sql/get_user_by_username.sql`.
///
/// > 🐿️ This function was generated automatically using v1.7.1 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_user_by_username(db, arg_1) {
  let decoder =
    decode.into({
      use id <- decode.parameter
      use username <- decode.parameter
      use email <- decode.parameter
      use password <- decode.parameter
      use invited_by <- decode.parameter
      GetUserByUsernameRow(
        id: id,
        username: username,
        email: email,
        password: password,
        invited_by: invited_by,
      )
    })
    |> decode.field(0, decode.int)
    |> decode.field(1, decode.string)
    |> decode.field(2, decode.string)
    |> decode.field(3, decode.string)
    |> decode.field(4, decode.optional(decode.int))

  "SELECT
    \"user\".id,
    \"user\".username,
    \"user\".email,
    \"user\".password,
    \"user\".invited_by
FROM
    \"user\"
WHERE
    \"user\".username = $1"
  |> pgo.execute(db, [pgo.text(arg_1)], decode.from(decoder, _))
}

/// A row you get from running the `get_user_id_from_session` query
/// defined in `./src/squirrels/sql/get_user_id_from_session.sql`.
///
/// > 🐿️ This type definition was generated automatically using v1.7.1 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetUserIdFromSessionRow {
  GetUserIdFromSessionRow(id: Int, user_id: Int)
}

/// Runs the `get_user_id_from_session` query
/// defined in `./src/squirrels/sql/get_user_id_from_session.sql`.
///
/// > 🐿️ This function was generated automatically using v1.7.1 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_user_id_from_session(db, arg_1) {
  let decoder =
    decode.into({
      use id <- decode.parameter
      use user_id <- decode.parameter
      GetUserIdFromSessionRow(id: id, user_id: user_id)
    })
    |> decode.field(0, decode.int)
    |> decode.field(1, decode.int)

  "SELECT
    user_session.id,
    user_session.user_id
FROM
    user_session
WHERE
    user_session.token = $1"
  |> pgo.execute(db, [pgo.text(arg_1)], decode.from(decoder, _))
}

/// A row you get from running the `get_user_by_id` query
/// defined in `./src/squirrels/sql/get_user_by_id.sql`.
///
/// > 🐿️ This type definition was generated automatically using v1.7.1 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetUserByIdRow {
  GetUserByIdRow(
    id: Int,
    username: String,
    email: String,
    password: String,
    invited_by: Option(Int),
  )
}

/// Runs the `get_user_by_id` query
/// defined in `./src/squirrels/sql/get_user_by_id.sql`.
///
/// > 🐿️ This function was generated automatically using v1.7.1 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_user_by_id(db, arg_1) {
  let decoder =
    decode.into({
      use id <- decode.parameter
      use username <- decode.parameter
      use email <- decode.parameter
      use password <- decode.parameter
      use invited_by <- decode.parameter
      GetUserByIdRow(
        id: id,
        username: username,
        email: email,
        password: password,
        invited_by: invited_by,
      )
    })
    |> decode.field(0, decode.int)
    |> decode.field(1, decode.string)
    |> decode.field(2, decode.string)
    |> decode.field(3, decode.string)
    |> decode.field(4, decode.optional(decode.int))

  "SELECT
    \"user\".id,
    \"user\".username,
    \"user\".email,
    \"user\".password,
    \"user\".invited_by
FROM
    \"user\"
WHERE
    \"user\".id = $1"
  |> pgo.execute(db, [pgo.int(arg_1)], decode.from(decoder, _))
}

/// A row you get from running the `get_user_is_admin` query
/// defined in `./src/squirrels/sql/get_user_is_admin.sql`.
///
/// > 🐿️ This type definition was generated automatically using v1.7.1 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetUserIsAdminRow {
  GetUserIsAdminRow(id: Int, user_id: Int)
}

/// Runs the `get_user_is_admin` query
/// defined in `./src/squirrels/sql/get_user_is_admin.sql`.
///
/// > 🐿️ This function was generated automatically using v1.7.1 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_user_is_admin(db, arg_1) {
  let decoder =
    decode.into({
      use id <- decode.parameter
      use user_id <- decode.parameter
      GetUserIsAdminRow(id: id, user_id: user_id)
    })
    |> decode.field(0, decode.int)
    |> decode.field(1, decode.int)

  "SELECT
    user_admin.id,
    user_admin.user_id
FROM
    user_admin
WHERE 
    user_admin.user_id = $1"
  |> pgo.execute(db, [pgo.int(arg_1)], decode.from(decoder, _))
}

/// A row you get from running the `get_auth_code_by_token` query
/// defined in `./src/squirrels/sql/get_auth_code_by_token.sql`.
///
/// > 🐿️ This type definition was generated automatically using v1.7.1 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetAuthCodeByTokenRow {
  GetAuthCodeByTokenRow(
    id: Int,
    token: String,
    creator_id: Int,
    used: Option(Bool),
  )
}

/// Runs the `get_auth_code_by_token` query
/// defined in `./src/squirrels/sql/get_auth_code_by_token.sql`.
///
/// > 🐿️ This function was generated automatically using v1.7.1 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_auth_code_by_token(db, arg_1) {
  let decoder =
    decode.into({
      use id <- decode.parameter
      use token <- decode.parameter
      use creator_id <- decode.parameter
      use used <- decode.parameter
      GetAuthCodeByTokenRow(
        id: id,
        token: token,
        creator_id: creator_id,
        used: used,
      )
    })
    |> decode.field(0, decode.int)
    |> decode.field(1, decode.string)
    |> decode.field(2, decode.int)
    |> decode.field(3, decode.optional(decode.bool))

  "SELECT
    auth_code.id,
    auth_code.token,
    auth_code.creator_id,
    auth_code.used
FROM
    auth_code
WHERE
    auth_code.token = $1"
  |> pgo.execute(db, [pgo.text(arg_1)], decode.from(decoder, _))
}

/// Runs the `create_forgot_password` query
/// defined in `./src/squirrels/sql/create_forgot_password.sql`.
///
/// > 🐿️ This function was generated automatically using v1.7.1 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn create_forgot_password(db, arg_1, arg_2) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "INSERT INTO
    user_forgot_password(user_id, token)
VALUES
    ($1, $2)"
  |> pgo.execute(db, [pgo.int(arg_1), pgo.text(arg_2)], decode.from(decoder, _))
}

/// Runs the `create_user_session` query
/// defined in `./src/squirrels/sql/create_user_session.sql`.
///
/// > 🐿️ This function was generated automatically using v1.7.1 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn create_user_session(db, arg_1, arg_2) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "INSERT INTO
    user_session(user_id, token)
VALUES
    ($1, $2)"
  |> pgo.execute(db, [pgo.int(arg_1), pgo.text(arg_2)], decode.from(decoder, _))
}

/// Runs the `update_user_password` query
/// defined in `./src/squirrels/sql/update_user_password.sql`.
///
/// > 🐿️ This function was generated automatically using v1.7.1 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn update_user_password(db, arg_1, arg_2) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "UPDATE
    \"user\"
SET
    password = $2
WHERE
    \"user\".id = $1"
  |> pgo.execute(db, [pgo.int(arg_1), pgo.text(arg_2)], decode.from(decoder, _))
}

/// A row you get from running the `get_user_by_forgot_password` query
/// defined in `./src/squirrels/sql/get_user_by_forgot_password.sql`.
///
/// > 🐿️ This type definition was generated automatically using v1.7.1 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetUserByForgotPasswordRow {
  GetUserByForgotPasswordRow(id: Int, user_id: Int)
}

/// Runs the `get_user_by_forgot_password` query
/// defined in `./src/squirrels/sql/get_user_by_forgot_password.sql`.
///
/// > 🐿️ This function was generated automatically using v1.7.1 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_user_by_forgot_password(db, arg_1) {
  let decoder =
    decode.into({
      use id <- decode.parameter
      use user_id <- decode.parameter
      GetUserByForgotPasswordRow(id: id, user_id: user_id)
    })
    |> decode.field(0, decode.int)
    |> decode.field(1, decode.int)

  "SELECT
    user_forgot_password.id,
    user_forgot_password.user_id
FROM
    user_forgot_password
WHERE
    user_forgot_password.token = $1
    AND user_forgot_password.used = FALSE"
  |> pgo.execute(db, [pgo.text(arg_1)], decode.from(decoder, _))
}

/// A row you get from running the `get_user_by_email` query
/// defined in `./src/squirrels/sql/get_user_by_email.sql`.
///
/// > 🐿️ This type definition was generated automatically using v1.7.1 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetUserByEmailRow {
  GetUserByEmailRow(
    id: Int,
    username: String,
    email: String,
    password: String,
    invited_by: Option(Int),
  )
}

/// Runs the `get_user_by_email` query
/// defined in `./src/squirrels/sql/get_user_by_email.sql`.
///
/// > 🐿️ This function was generated automatically using v1.7.1 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_user_by_email(db, arg_1) {
  let decoder =
    decode.into({
      use id <- decode.parameter
      use username <- decode.parameter
      use email <- decode.parameter
      use password <- decode.parameter
      use invited_by <- decode.parameter
      GetUserByEmailRow(
        id: id,
        username: username,
        email: email,
        password: password,
        invited_by: invited_by,
      )
    })
    |> decode.field(0, decode.int)
    |> decode.field(1, decode.string)
    |> decode.field(2, decode.string)
    |> decode.field(3, decode.string)
    |> decode.field(4, decode.optional(decode.int))

  "SELECT
    \"user\".id,
    \"user\".username,
    \"user\".email,
    \"user\".password,
    \"user\".invited_by
FROM
    \"user\"
WHERE
    \"user\".email = $1"
  |> pgo.execute(db, [pgo.text(arg_1)], decode.from(decoder, _))
}

/// Runs the `update_forgot_password_as_used` query
/// defined in `./src/squirrels/sql/update_forgot_password_as_used.sql`.
///
/// > 🐿️ This function was generated automatically using v1.7.1 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn update_forgot_password_as_used(db, arg_1) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "UPDATE
    user_forgot_password
SET
    used = TRUE
WHERE
    token = $1"
  |> pgo.execute(db, [pgo.text(arg_1)], decode.from(decoder, _))
}
