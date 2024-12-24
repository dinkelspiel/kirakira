import gleam/option.{Some}
import gleam/result
import pog
import server/env.{get_env}

pub fn get_connection_raw() -> Result(pog.Connection, String) {
  use env <- result.try(get_env())

  Ok(pog.connect(
    pog.Config(
      ..pog.default_config(),
      host: env.db_host,
      database: env.db_name,
      port: env.db_port,
      user: env.db_user,
      password: Some(env.db_password),
      pool_size: 15,
    ),
  ))
}

pub fn get_connection(
  fun: fn(pog.Connection) -> Result(a, String),
) -> Result(a, String) {
  case get_connection_raw() {
    Ok(x) -> {
      let a = fun(x)
      pog.disconnect(x)
      a
    }
    Error(e) -> Error(e)
  }
}
