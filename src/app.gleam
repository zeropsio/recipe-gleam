import gleam/http.{Get}
import gleam/http/response.{type Response}
import gleam/http/request.{type Request}
import gleam/bytes_builder
import gleam/io
import gleam/json
import gleam/pgo
import gleam/erlang/process
import database
import config
import mist.{type Connection, type ResponseData}

pub fn main() {
  case config.get_db_connection() {
    Ok(db) -> {
      let assert Ok(_) =
        mist.new(my_service(db))
        |> mist.port(3000)
        |> mist.start_http

      io.println("Server started on port 3000")
      process.sleep_forever()
    }
    Error(Nil) -> {
      io.println("Failed to initialize database connection")
      process.sleep_forever()
    }
  }
}

fn my_service(
  db: pgo.Connection,
) -> fn(Request(Connection)) -> Response(ResponseData) {
  fn(request: Request(Connection)) -> Response(ResponseData) {
    case request.method {
      Get -> handle_get_request(db)
      _ -> json_response(404, json.object([
        #("error", json.string("Method not allowed"))
      ]))
    }
  }
}

fn handle_get_request(db: pgo.Connection) -> Response(ResponseData) {
  case database.add_entry_and_get_count(db) {
    Ok(#(uuid, count)) -> {
      let response_body = json.object([
        #("uuid", json.string(uuid)),
        #("count", json.int(count)),
      ])
      json_response(200, response_body)
    }
    Error(_) -> {
      json_response(500, json.object([
        #("error", json.string("Database error"))
      ]))
    }
  }
}

fn json_response(
  status: Int,
  body: json.Json,
) -> Response(ResponseData) {
  response.new(status)
  |> response.set_header("content-type", "application/json")
  |> response.set_body(bytes_builder.from_string(json.to_string(body)))
}