import decode
import glenv

pub type Env {
  Env(
    db_host: String,
    db_password: String,
    db_port: Int,
    db_user: String,
    db_name: String,
    resend_api_key: String,
    resend_email: String,
  )
}

pub fn get_env() {
  let definitions = [
    #("DB_HOST", glenv.String),
    #("DB_PASSWORD", glenv.String),
    #("DB_PORT", glenv.Int),
    #("DB_USER", glenv.String),
    #("DB_NAME", glenv.String),
    #("RESEND_API_KEY", glenv.String),
    #("RESEND_EMAIL", glenv.String),
  ]

  let decoder =
    decode.into({
      use db_host <- decode.parameter
      use db_password <- decode.parameter
      use db_port <- decode.parameter
      use db_user <- decode.parameter
      use db_name <- decode.parameter
      use resend_api_key <- decode.parameter
      use resend_email <- decode.parameter

      Env(
        db_host,
        db_password,
        db_port,
        db_user,
        db_name,
        resend_api_key,
        resend_email,
      )
    })
    |> decode.field("DB_HOST", decode.string)
    |> decode.field("DB_PASSWORD", decode.string)
    |> decode.field("DB_PORT", decode.int)
    |> decode.field("DB_USER", decode.string)
    |> decode.field("DB_NAME", decode.string)
    |> decode.field("RESEND_API_KEY", decode.string)
    |> decode.field("RESEND_EMAIL", decode.string)

  case glenv.load(decoder, definitions) {
    Ok(env) -> Ok(env)
    Error(err) ->
      case err {
        glenv.DefinitionMismatchError(_) ->
          Error("Definition mismatch for env in server environment")
        glenv.NotFoundError(key) ->
          Error(
            "The env key '"
            <> key
            <> "' was not found in the server environment",
          )
        glenv.ParseError(key, _) ->
          Error(
            "The env key '"
            <> key
            <> "' was of the wrong type in the server environment",
          )
      }
  }
}
