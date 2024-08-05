import cake
import cake/dialect/mysql_dialect
import gleam/dynamic.{type Dynamic}
import gleam/option.{Some}
import gmysql
import server/env.{get_env}

fn get_connection() {
  let env = get_env()

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
