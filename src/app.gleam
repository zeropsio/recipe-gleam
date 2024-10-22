import mist
import gleam/io
import gleam/int
import gleam/bytes_builder
import gleam/erlang/process
import gleam/json
import gleam/http/response.{Response}
import config
import database

pub fn main() {

  let port = 3000
  let assert Ok(_) =
    json_service
    |> mist.new
    |> mist.port(port)
    |> mist.start_http

  io.println("Server running at: http://localhost:" <> int.to_string(port))
  process.sleep_forever()
}

fn json_service(_) {
  case config.get_db_connection() {
    Ok(conn) -> {
      case database.add_entry_and_get_count(conn) {
        Ok(#(uuid, count)) -> {
          let message = "This is a simple, basic Gleam application running on Zerops.io,
      each request adds an entry to the PostgreSQL database and returns a count.
      See the source repository (https://github.com/nermalcat69/gleam-mist-pgo) for more information."

          Response(
            200,
            [#("content-type", "application/json")],
            mist.Bytes(bytes_builder.from_string(
              json.to_string(json.object([
                #("message", json.string(message)),
                #("newEntry", json.string(uuid)),
                #("count", json.string(int.to_string(count)))
              ]))
            ))
          )
        }
        Error(_) -> {
          Response(
            500,
            [#("content-type", "application/json")],
            mist.Bytes(bytes_builder.from_string(
              json.to_string(json.object([
                #("error", json.string("Database operation failed"))
              ]))
            ))
          )
        }
      }
    }
    Error(_) -> {
      Response(
        500,
        [#("content-type", "application/json")],
        mist.Bytes(bytes_builder.from_string(
          json.to_string(json.object([
            #("error", json.string("Database connection failed"))
          ]))
        ))
      )
    }
  }
}