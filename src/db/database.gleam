import gleam/string
import gleam/pgo
import gleam/io
import gleam/dynamic
import gleam/int
import gluid

pub fn add_entry_and_get_count(conn: pgo.Connection) -> Result(#(String, Int), String) {
  io.println("Adding entry and getting count")
  let uuid = gluid.guidv4()
  io.println("Generated UUID: " <> uuid)
  
  let insert_query = "INSERT INTO entries (uuid) VALUES ($1)"
  io.println("Executing insert query with UUID")
  
  case pgo.execute(
    query: insert_query,
    on: conn,
    with: [pgo.text(uuid)],
    expecting: dynamic.dynamic
  ) {
    Ok(_) -> {
      io.println("Entry added successfully")
      case get_count(conn) {
        Ok(count) -> Ok(#(uuid, count))
        Error(err) -> Error(err)
      }
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
    expecting: fn(row) {
      dynamic.element(0, dynamic.int)(row)
    }
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