//// Module for use with [based](https://hex.pm/packages/based)

import based
import gleam/dynamic.{type Dynamic}
import gleam/list
import gleam/result
import gmysql.{type Config, type Connection}

pub fn adapter(config: Config, conn_count: Int, max_reconnects_per_sec: Int) {
  based.BasedAdapter(
    conf: config,
    service: fn(query: based.Query, connection: Connection) -> Result(
      List(Dynamic),
      based.BasedError,
    ) {
      let params =
        list.map(query.values, fn(val) {
          case val {
            based.String(str) -> gmysql.to_param(str)
            based.Float(float) -> gmysql.to_param(float)
            based.Int(int) -> gmysql.to_param(int)
            based.Bool(bool) -> gmysql.to_param(bool)
            based.Null -> gmysql.to_param(Nil)
          }
        })

      gmysql.query(
        query.sql,
        on: connection,
        with: params,
        expecting: dynamic.dynamic,
      )
      |> result.map_error(fn(err) {
        todo
        // based.BasedError()
      })
    },
    with_connection: fn(config: Config, fxn: fn(Connection) -> a) -> a { todo },
  )
}
