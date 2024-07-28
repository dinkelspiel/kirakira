-module(gmysql_ffi).

-export([
    connect/1,
    exec/3,
    to_param/1,
    null_param/0,
    query/4,
    with_connection/2,
    with_transaction/3,
    close/1,
    from_timeout/1,
    to_pid/1,
    from_pid/1
]).

connect(ConnectOpts) ->
    try
        case mysql:start_link(ConnectOpts) of
            {ok, Connection} -> {ok, Connection};
            {error, Reason} -> {error, Reason};
            ignore -> {error, nil}
        end
    catch
        ExitReason -> {error, ExitReason}
    end.

exec(Connection, Query, Timeout) ->
    case query(Connection, Query, [], Timeout) of
        {ok, _} -> {ok, nil};
        {error, Reason} -> {error, Reason}
    end.

to_param(Param) ->
    Param.

null_param() ->
    null.

to_pid(Connection) ->
    Connection.

from_pid(Pid) ->
    Pid.

from_timeout(Timeout) ->
    case Timeout of
        infinity -> infinity;
        {_, X} when is_integer(X) -> X
    end.

query(Connection, Query, Params, Timeout) ->
    case mysql:query(Connection, Query, Params, from_timeout(Timeout)) of
        ok -> {ok, []};
        {ok, ok} -> {ok, []};
        {ok, _, Rows} -> {ok, Rows};
        {ok, ResultsList} -> {ok, ResultsList};
        {error, {Code, _, Message}} -> {error, {server_error, Code, Message}};
        {error, Any} -> {error, {unknown_error, Any}}
    end.

with_connection(ConnectOpts, Function) ->
    case connect(ConnectOpts) of
        {error, Err} -> {error, Err};
        {ok, Connection} -> {ok, Function(Connection)}
    end.

with_transaction(Connection, Function, Retries) ->
    F = fun() ->
        case Function(Connection) of
            {ok, Result} -> {ok, Result};
            {error, Reason} ->
                throw({transaction_function_errored, Reason})
        end
    end,
    case mysql:transaction(Connection, F, Retries) of
        {atomic, Result} -> {ok, Result};
        {aborted, {throw, {transaction_function_errored, Reason}}} -> {error, {function_error, Reason}};
        {aborted, Reason} -> {error, {other_error, Reason}}
    end.

close(Connection) ->
    mysql:stop(Connection),
    nil.
