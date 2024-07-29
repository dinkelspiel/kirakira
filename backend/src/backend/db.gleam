import cake
import cake/dialect/mysql_dialect
import decode
import gleam/dynamic.{type Dynamic}
import gleam/option.{Some}
import glenv
import gmysql

pub type Env {
  Env(
    db_host: String,
    db_password: String,
    db_port: Int,
    db_user: String,
    db_name: String,
  )
}

fn get_connection() {
  let definitions = [
    #("DB_HOST", glenv.String),
    #("DB_PASSWORD", glenv.String),
    #("DB_PORT", glenv.Int),
    #("DB_USER", glenv.String),
    #("DB_NAME", glenv.String),
  ]

  let decoder =
    decode.into({
      use db_host <- decode.parameter
      use db_password <- decode.parameter
      use db_port <- decode.parameter
      use db_user <- decode.parameter
      use db_name <- decode.parameter

      Env(db_host, db_password, db_port, db_user, db_name)
    })
    |> decode.field("DB_HOST", decode.string)
    |> decode.field("DB_PASSWORD", decode.string)
    |> decode.field("DB_PORT", decode.int)
    |> decode.field("DB_USER", decode.string)
    |> decode.field("DB_NAME", decode.string)

  let assert Ok(env) = glenv.load(decoder, definitions)

  let assert Ok(connection) =
    gmysql.connect(gmysql.Config(
      host: env.db_host,
      port: env.db_port,
      user: Some(env.db_user),
      password: Some(env.db_password),
      connection_mode: gmysql.Asynchronous,
      connection_timeout: gmysql.Infinity,
      database: env.db_name,
      keep_alive: 1000,
    ))

  connection
}

pub fn execute_read(
  read_query: cake.ReadQuery,
  params: List(gmysql.Param),
  decoder: fn(dynamic.Dynamic) -> Result(a, List(dynamic.DecodeError)),
) {
  let prepared_statement =
    read_query
    |> mysql_dialect.read_query_to_prepared_statement
    |> cake.get_sql

  let connection = get_connection()
  let rows = gmysql.query(prepared_statement, connection, params, decoder)
  gmysql.disconnect(connection)
  rows
}

pub fn execute_write(
  write_query: cake.WriteQuery(a),
  params: List(gmysql.Param),
) {
  let prepared_statement =
    write_query
    |> mysql_dialect.write_query_to_prepared_statement
    |> cake.get_sql

  let connection = get_connection()
  let rows = gmysql.query(prepared_statement, connection, params, dynamic.int)
  gmysql.disconnect(connection)
  rows
}

@external(erlang, "erlang", "list_to_tuple")
pub fn list_to_tuple(dynamic: Dynamic) -> Dynamic
