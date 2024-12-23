import gleam/option.{Some}
import gleam/result
import pog
import server/env.{get_env}

pub fn get_connection() {
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
