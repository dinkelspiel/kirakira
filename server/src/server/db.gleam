import gleam/dynamic/decode
import gleam/list
import gleam/option.{Some}
import gleam/result
import parrot/dev
import server/env.{get_env}
import shork

pub fn get_connection_raw() -> Result(shork.Connection, String) {
  use env <- result.try(get_env())

  Ok(
    shork.default_config()
    |> shork.host(env.db_host)
    |> shork.database(env.db_name)
    |> shork.port(env.db_port)
    |> shork.user(env.db_user)
    |> shork.password(env.db_password)
    |> shork.connect,
  )
}

pub fn get_connection(
  fun: fn(shork.Connection) -> Result(a, String),
) -> Result(a, String) {
  case get_connection_raw() {
    Ok(x) -> {
      let a = fun(x)
      shork.disconnect(x)
      a
    }
    Error(e) -> Error(e)
  }
}

pub fn parrot_to_shork(param: dev.Param) {
  case param {
    dev.ParamBool(x) -> shork.bool(x)
    dev.ParamFloat(x) -> shork.float(x)
    dev.ParamInt(x) -> shork.int(x)
    dev.ParamString(x) -> shork.text(x)
    dev.ParamBitArray(_) -> panic as "shork does not support bit arrays"
    dev.ParamTimestamp(_) ->
      panic as "timestamp parameter needs to be implemented"
    dev.ParamDynamic(_) -> panic as "dynamic parameter need to implemented"
  }
}

pub fn query(
  db db: shork.Connection,
  b b: #(String, List(dev.Param), decode.Decoder(a)),
) {
  b.0
  |> shork.query()
  |> shork.returning(b.2)
  |> list.fold(b.1, _, fn(acc, param) {
    let param = parrot_to_shork(param)
    shork.parameter(acc, param)
  })
  |> shork.execute(db)
}

pub fn exec(db db: shork.Connection, b b: #(String, List(dev.Param))) {
  b.0
  |> shork.query()
  |> list.fold(b.1, _, fn(acc, param) {
    let param = parrot_to_shork(param)
    shork.parameter(acc, param)
  })
  |> shork.execute(db)
}
