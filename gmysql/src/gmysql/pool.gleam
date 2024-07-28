import gleam/bool
import gleam/erlang
import gleam/erlang/process.{type Subject}
import gleam/function
import gleam/iterator
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/otp/actor.{type Next, Continue, Stop}
import gleam/otp/intensity_tracker.{type IntensityTracker}
import gmysql.{type Config, type Connection}

pub opaque type Pool {
  Pool(actor: Subject(Message))
}

pub opaque type Message {
  UpdateState(fn(State) -> State)
  Initialize(subject: Subject(Message))
  Shutdown
  Restart(Connection)
  RestartAll
  StartNew
  Checkout(client: Subject(Result(Connection, Nil)))
  Checkin(connection: Connection)
  Tick(Subject(Message))
}

type State {
  State(slots: List(Slot), config: Config, rate_limit: IntensityTracker)
}

type Slot {
  Slot(connection: Option(Connection), checked_out: Bool)
}

pub fn connect(
  config: Config,
  count: Int,
  limit max_connections_per_second: Int,
) {
  let slots =
    iterator.repeat(Slot(connection: None, checked_out: False))
    |> iterator.take(count)
    |> iterator.to_list

  let assert Ok(actor) =
    actor.start(
      State(
        slots: slots,
        config: config,
        rate_limit: intensity_tracker.new(
          limit: max_connections_per_second,
          period: 1000,
        ),
      ),
      handle_message,
    )

  process.send(actor, Initialize(actor))

  Pool(actor)
}

pub fn disconnect(pool: Pool) {
  actor.send(pool.actor, Shutdown)
}

pub fn restart_connection(pool: Pool, connection: Connection) {
  actor.send(pool.actor, Restart(connection))
}

pub fn restart_all_connections(pool: Pool) {
  actor.send(pool.actor, RestartAll)
}

pub fn new_connection(pool: Pool) {
  actor.send(pool.actor, StartNew)
}

pub fn checkout_connection(pool: Pool, timeout: Int) {
  actor.call(pool.actor, Checkout, timeout)
}

pub fn checkin_connection(pool: Pool, connection: Connection) {
  actor.send(pool.actor, Checkin(connection))
}

pub type WithConnectionError {
  CouldNotCheckout
}

pub fn with_connection(
  pool: Pool,
  wait checkout_timeout: Int,
  with function: fn(Connection) -> a,
) -> Result(a, WithConnectionError) {
  let until = erlang.system_time(erlang.Millisecond) + checkout_timeout
  with_connection_loop(pool, until, checkout_timeout, function)
}

fn with_connection_loop(
  pool: Pool,
  until: Int,
  timeout: Int,
  function: fn(Connection) -> a,
) -> Result(a, WithConnectionError) {
  use <- bool.guard(
    when: erlang.system_time(erlang.Millisecond) > until,
    return: Error(CouldNotCheckout),
  )

  case checkout_connection(pool, timeout / 3) {
    Ok(connection) -> {
      let result = function(connection)
      checkin_connection(pool, connection)

      Ok(result)
    }
    Error(_) -> {
      process.sleep(timeout / 6)
      with_connection_loop(pool, until, timeout, function)
    }
  }
}

fn handle_message(message: Message, state: State) -> Next(Message, State) {
  case message {
    UpdateState(..) -> handle_update_state(message, state)
    Initialize(..) -> handle_init(message, state)
    Shutdown -> handle_shutdown(message, state)
    Restart(..) -> handle_restart(message, state)
    RestartAll -> handle_restart_all(message, state)
    StartNew -> handle_start_new(message, state)
    Checkout(..) -> handle_checkout(message, state)
    Checkin(..) -> handle_checkin(message, state)
    Tick(..) -> handle_tick(message, state)
  }
}

fn handle_update_state(message: Message, state: State) -> Next(Message, State) {
  let assert UpdateState(transform) = message
  let new_state = transform(state)

  Continue(new_state, None)
}

fn handle_crashed_connection(exit_message: process.ExitMessage) -> Message {
  let process.ExitMessage(pid, reason) = exit_message

  let connection = gmysql.from_pid(pid)
  case reason {
    process.Normal ->
      UpdateState(fn(state) {
        State(
          ..state,
          slots: list.filter(state.slots, fn(slot) {
            slot.connection == Some(connection)
          }),
        )
      })
    _ ->
      UpdateState(fn(state) {
        State(
          ..state,
          slots: list.map(state.slots, fn(slot) {
            case slot.connection == Some(connection) {
              True -> Slot(..slot, connection: None)
              False -> slot
            }
          }),
        )
      })
  }
}

fn handle_init(message: Message, state: State) -> Next(Message, State) {
  let assert Initialize(self) = message
  process.trap_exits(True)

  let selector =
    process.new_selector()
    |> process.selecting(self, function.identity)
    |> process.selecting_trapped_exits(handle_crashed_connection)

  process.send(self, Tick(self))

  Continue(state, Some(selector))
}

fn handle_shutdown(_message: Message, state: State) -> Next(Message, State) {
  list.each(state.slots, fn(slot) {
    case slot.connection {
      None -> Nil
      Some(conn) -> gmysql.disconnect(conn)
    }
  })

  Stop(process.Normal)
}

fn handle_restart(message: Message, state: State) -> Next(Message, State) {
  let assert Restart(conn) = message
  let pid = gmysql.to_pid(conn)
  process.kill(pid)

  actor.continue(state)
}

fn handle_restart_all(_message: Message, state: State) -> Next(Message, State) {
  list.each(state.slots, fn(slot) {
    case slot.connection {
      None -> Nil
      Some(conn) -> gmysql.to_pid(conn) |> process.kill
    }
  })

  actor.continue(state)
}

fn handle_start_new(_message: Message, state: State) -> Next(Message, State) {
  actor.continue(
    State(
      ..state,
      slots: [Slot(connection: None, checked_out: False), ..state.slots],
    ),
  )
}

fn handle_checkout(message: Message, state: State) -> Next(Message, State) {
  let assert Checkout(client) = message

  let #(connection, slots) =
    list.map_fold(state.slots, None, fn(connection, slot) {
      case connection, slot {
        Some(..), _ -> #(connection, slot)
        None, Slot(connection: Some(conn), checked_out: False) -> #(
          Some(conn),
          Slot(..slot, checked_out: True),
        )
        _, _ -> #(connection, slot)
      }
    })

  connection |> option.to_result(Nil) |> process.send(client, _)

  actor.continue(State(..state, slots: slots))
}

fn handle_checkin(message: Message, state: State) -> Next(Message, State) {
  let assert Checkin(connection) = message

  actor.continue(
    State(
      ..state,
      slots: list.map(state.slots, fn(slot) {
        case slot.connection == Some(connection) {
          True -> Slot(..slot, checked_out: False)
          False -> slot
        }
      }),
    ),
  )
}

fn handle_tick(message: Message, state: State) -> Next(Message, State) {
  let assert Tick(self) = message

  let #(rate_limiter, slots) =
    list.map_fold(state.slots, state.rate_limit, fn(rate_limit, slot) {
      case intensity_tracker.add_event(rate_limit), slot {
        Ok(limiter), Slot(connection: None, ..) ->
          case gmysql.connect(state.config) {
            Ok(connection) -> #(
              limiter,
              Slot(connection: Some(connection), checked_out: False),
            )
            Error(_) -> #(limiter, slot)
          }
        _, Slot(connection: None, ..) -> #(
          rate_limit,
          Slot(..slot, checked_out: False),
        )
        _, slot -> #(rate_limit, slot)
      }
    })

  process.send_after(self, 250, Tick(self))

  actor.continue(State(..state, slots: slots, rate_limit: rate_limiter))
}
