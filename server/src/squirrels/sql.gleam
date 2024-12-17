import decode
import gleam/option.{type Option}
import gleam/pgo

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
WHERE auth_code.token = $1
"
  |> pgo.execute(db, [pgo.text(arg_1)], decode.from(decoder, _))
}
