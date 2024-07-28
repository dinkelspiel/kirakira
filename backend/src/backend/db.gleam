import cake
import cake/dialect/mysql_dialect
import gleam/dynamic.{type Dynamic}
import gleam/erlang/process
import gleam/int
import gleam/option.{Some}
import gmysql

fn get_connection() {
  let assert Ok(connection) =
    gmysql.connect(gmysql.Config(
      host: "0.0.0.0",
      port: 3306,
      user: Some("root"),
      password: Some("kirakira"),
      connection_mode: gmysql.Asynchronous,
      connection_timeout: gmysql.Infinity,
      database: "kirakira",
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
