import gleam/dynamic.{type Dynamic}
import gleam/erlang/charlist.{type Charlist}
import gleam/erlang/process.{type Pid}
import gleam/option.{type Option, None, Some}

pub type Connection

pub type Timeout {
  Infinity
  Ms(Int)
}

pub type ConnectionMode {
  Synchronous
  Asynchronous
  Lazy
}

type ConnectionOption {
  Host(Charlist)
  Port(Int)
  User(Charlist)
  Password(Charlist)
  Database(Charlist)
  ConnectMode(ConnectionMode)
  ConnectTimeout(Int)
  KeepAlive(Int)
}

@external(erlang, "gmysql_ffi", "from_timeout")
fn from_timeout(in: Timeout) -> Int

pub type Config {
  Config(
    host: String,
    port: Int,
    user: Option(String),
    password: Option(String),
    database: String,
    connection_mode: ConnectionMode,
    connection_timeout: Timeout,
    keep_alive: Int,
  )
}

pub fn default_config() -> Config {
  Config(
    host: "localhost",
    port: 3306,
    user: None,
    password: None,
    database: "db",
    connection_mode: Asynchronous,
    connection_timeout: Infinity,
    keep_alive: 1000,
  )
}

fn config_to_connection_options(config: Config) -> List(ConnectionOption) {
  [
    Some(Host(config.host |> charlist.from_string)),
    Some(Port(config.port)),
    option.map(config.user, charlist.from_string) |> option.map(User),
    option.map(config.password, charlist.from_string) |> option.map(Password),
    Some(Database(config.database |> charlist.from_string)),
    Some(ConnectMode(config.connection_mode)),
    Some(ConnectTimeout(config.connection_timeout |> from_timeout)),
    Some(KeepAlive(config.keep_alive)),
  ]
  |> option.values
}

pub type Error {
  ServerError(Int, BitArray)
  UnknownError(Dynamic)
  DecodeError(dynamic.DecodeErrors)
}

pub type Param

@external(erlang, "gmysql_ffi", "connect")
fn connect_ffi(options: List(ConnectionOption)) -> Result(Connection, Dynamic)

pub fn connect(config: Config) {
  config_to_connection_options(config)
  |> connect_ffi
}

@external(erlang, "gmysql_ffi", "with_connection")
fn with_connection_ffi(
  options: List(ConnectionOption),
  with function: fn(Connection) -> a,
) -> Result(a, Dynamic)

pub fn with_connection(
  config: Config,
  with function: fn(Connection) -> a,
) -> Result(a, Dynamic) {
  config_to_connection_options(config)
  |> with_connection_ffi(function)
}

@external(erlang, "gmysql_ffi", "exec")
fn exec_internal(
  connection: Connection,
  query: String,
  timeout: a,
) -> Result(Nil, Error)

pub fn exec(sql: String, on connection: Connection) -> Result(Nil, Error) {
  exec_with_timeout(sql, connection, Infinity)
}

pub fn exec_with_timeout(
  sql: String,
  on connection: Connection,
  until timeout: Timeout,
) -> Result(Nil, Error) {
  exec_internal(connection, sql, timeout)
}

@external(erlang, "gmysql_ffi", "to_param")
pub fn to_param(param: a) -> Param

@external(erlang, "gmysql_ffi", "null_param")
pub fn null_param() -> Param

@external(erlang, "gmysql_ffi", "to_pid")
pub fn to_pid(connection: Connection) -> Pid

/// Danger, this is primarily for internal use, do not pass in pids that you did not
/// get from the `to_pid/1` function.
@external(erlang, "gmysql_ffi", "from_pid")
pub fn from_pid(connection: Pid) -> Connection

@external(erlang, "gmysql_ffi", "query")
fn query_internal(
  connection: Connection,
  query: String,
  params: List(Param),
  timeout: Timeout,
) -> Result(Dynamic, Error)

pub fn query(
  sql: String,
  on connection: Connection,
  with arguments: List(Param),
  expecting decoder: fn(Dynamic) -> Result(a, List(dynamic.DecodeError)),
) -> Result(List(a), Error) {
  query_with_timeout(sql, connection, arguments, decoder, Infinity)
}

pub fn query_with_timeout(
  sql: String,
  on connection: Connection,
  with arguments: List(Param),
  expecting decoder: fn(Dynamic) -> Result(a, List(dynamic.DecodeError)),
  until timeout: Timeout,
) -> Result(List(a), Error) {
  case query_internal(connection, sql, arguments, timeout) {
    Error(int) -> Error(int)
    Ok(dyn) ->
      case dynamic.list(decoder)(dyn) {
        Ok(decoded) -> Ok(decoded)
        Error(decode_errors) -> Error(DecodeError(decode_errors))
      }
  }
}

pub type TransactionError(a) {
  FunctionError(a)
  OtherError(Dynamic)
}

/// Execute a function within a transaction.
/// If the function throws or returns an error, it will rollback.
/// You can nest this function, which will create a savepoint.
@external(erlang, "gmysql_ffi", "with_transaction")
pub fn with_transaction(
  connection: Connection,
  retry retries: Int,
  with function: fn(Connection) -> Result(a, b),
) -> Result(a, TransactionError(b))

@external(erlang, "gmysql_ffi", "close")
pub fn disconnect(connection: Connection) -> Nil
