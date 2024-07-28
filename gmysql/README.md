# gmysql

[![Package Version](https://img.shields.io/hexpm/v/gmysql)](https://hex.pm/packages/gmysql)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/gmysql/)

```sh
gleam add gmysql
```
```gleam
import gmysql
import gleam/dynamic

pub fn main() {
  let assert Ok(connection) = gmysql.connect(gmysql.default_config())
  gmysql.query(
    connection,
    "SELECT * FROM users WHERE id = ?;",
    [gmysql.to_param("user_id")],
    1000,
    dynamic.tuple3(dynamic.string, dynamic.string, dynamic.string)
  )
}
```

Further documentation can be found at <https://hexdocs.pm/gmysql>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
gleam shell # Run an Erlang shell
```
