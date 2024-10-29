import gleam/http.{Get}
import gleam/json
import gleam/io
import wisp.{type Request, type Response}
import gleam/pgo
import gleam/erlang/process
import db/database
import db/config
import gleam/result
import mist
import wisp/wisp_mist

pub type AppError {
  DatabaseError(String)
  ConfigError(String)
  ServerError(String)
}

pub type ApiResponse(a) {
  ApiResponse(
    data: a,
    status: Int,
  )
}

pub type RootData {
  RootData(
    message: String,
    new_entry: String,
    count: Int,
  )
}

pub fn main() {
  wisp.configure_logger()
  let secret_key_base = wisp.random_string(64)

  use db_conn <- result.map(setup_database())
  
  let handler = fn(req) { handle_request(req, db_conn) }

  let assert Ok(_) =
    handler
    |> wisp_mist.handler(secret_key_base)
    |> mist.new
    |> mist.port(3000)
    |> mist.start_http

  process.sleep_forever()
}

fn setup_database() -> Result(pgo.Connection, AppError) {
  use db_conn <- result.try(
    config.get_db_connection()
    |> result.map_error(fn(_) { ConfigError("Database connection failed") })
  )

  io.println("✓ Server initialized with database connection")
  Ok(db_conn)
}

pub fn handle_request(req: Request, conn: pgo.Connection) -> Response {
  case req.method, wisp.path_segments(req) {
    Get, [] -> handle_root(conn)
    Get, ["status"] -> handle_status()
    _, _ -> wisp.not_found()
  }
}

fn handle_root(conn: pgo.Connection) -> Response {
  case process_root_request(conn) {
    Ok(ApiResponse(data: data, status: status)) -> {
      wisp.json_response(
        json.to_string_builder(encode_root_data(data)),
        status,
      )
    }
    Error(error) -> {
      let #(status, message) = error_response(error)
      wisp.json_response(
        json.to_string_builder(encode_error(message)),
        status,
      )
    }
  }
}

fn process_root_request(conn: pgo.Connection) -> Result(ApiResponse(RootData), AppError) {
  use #(uuid, count) <- result.try(
    database.add_entry_and_get_count(conn)
    |> result.map_error(DatabaseError)
  )
  
  let data = RootData(
    message: "This is a simple Gleam application running on Zerops.io, each request adds an entry to the PostgreSQL database and returns a count. See the source repository (https://github.com/zeropsio/recipe-nodejs) for more information.",
    new_entry: uuid,
    count: count,
  )

  Ok(ApiResponse(data: data, status: 201))
}

fn handle_status() -> Response {
  wisp.json_response(
    json.to_string_builder(encode_status_response()),
    200,
  )
}

fn encode_root_data(data: RootData) -> json.Json {
  json.object([
    #("message", json.string(data.message)),
    #("newEntry", json.string(data.new_entry)),
    #("count", json.int(data.count)),
  ])
}

fn encode_status_response() -> json.Json {
  json.object([#("status", json.string("UP"))])
}

fn encode_error(message: String) -> json.Json {
  json.object([#("error", json.string(message))])
}

fn error_response(error: AppError) -> #(Int, String) {
  case error {
    ConfigError(msg) -> #(500, "Configuration error: " <> msg)
    DatabaseError(msg) -> #(500, "Database error: " <> msg)
    ServerError(msg) -> #(500, "Server error: " <> msg)
  }
}
