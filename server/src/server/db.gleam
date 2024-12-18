import gleam/option.{Some}
import gleam/pgo
import server/env.{get_env}

pub fn get_connection() {
  let env = get_env()

  pgo.connect(
    pgo.Config(
      ..pgo.default_config(),
      host: env.db_host,
      database: env.db_name,
      port: env.db_port,
      user: env.db_user,
      password: Some(env.db_password),
      pool_size: 15,
    ),
  )
}
