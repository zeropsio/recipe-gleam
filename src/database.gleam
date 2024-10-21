import gleam/string
import gleam/pgo
import gleam/io
import gleam/dynamic
import gleam/int

pub fn add_entry_and_get_count(conn: pgo.Connection) -> Result(Int, String) {
  io.println("Adding entry and getting count")
  // Insert a new entry
  let insert_query = "INSERT INTO entries (created_at) VALUES (NOW())"
  io.println("Executing insert query: " <> insert_query)
  case pgo.execute(
    query: insert_query,
    on: conn,
    with: [],
    expecting: dynamic.dynamic
  ) {
    Ok(_) -> {
      io.println("Entry added successfully")
      get_count(conn)
    }
    Error(err) -> {
      let error_message = query_error_to_string(err)
      io.println("Failed to add entry: " <> error_message)
      Error("Failed to add entry: " <> error_message)
    }
  }
}

fn get_count(conn: pgo.Connection) -> Result(Int, String) {
  let count_query = "SELECT COUNT(*) FROM entries"
  io.println("Executing count query: " <> count_query)
  case pgo.execute(
    query: count_query,
    on: conn,
    with: [],
    expecting: dynamic.int
  ) {
    Ok(result) -> {
      case result.rows {
        [count] -> {
          io.println("Count retrieved successfully: " <> int.to_string(count))
          Ok(count)
        }
        _ -> {
          io.println("Unexpected result format")
          Error("Unexpected result format")
        }
      }
    }
    Error(err) -> {
      let error_message = query_error_to_string(err)
      io.println("Failed to get count: " <> error_message)
      Error("Failed to get count: " <> error_message)
    }
  }
}

fn query_error_to_string(error: pgo.QueryError) -> String {
  case error {
    pgo.ConstraintViolated(message: message, constraint: constraint, detail: detail) ->
      "Constraint violated: " <> message <> " (Constraint: " <> constraint <> ", Detail: " <> detail <> ")"

    pgo.PostgresqlError(code: code, name: name, message: message) ->
      "PostgreSQL error: " <> message <> " (Code: " <> code <> ", Name: " <> name <> ")"

    pgo.UnexpectedArgumentCount(expected: expected, got: got) ->
      "Unexpected argument count. Expected: " <> int.to_string(expected) <> ", Got: " <> int.to_string(got)

    pgo.UnexpectedArgumentType(expected: expected, got: got) ->
      "Unexpected argument type. Expected: " <> expected <> ", Got: " <> got

    pgo.UnexpectedResultType(errors) ->
      "Unexpected result type: " <> string.inspect(errors)

    pgo.ConnectionUnavailable ->
      "Connection unavailable"
  }
}