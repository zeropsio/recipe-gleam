import gleam/http.{Get}
import gleam/json
import gleam/io
import wisp.{type Request, type Response, not_found}
import wisp/wisp_mist
import gleam/pgo
import database
import config
import mist
import gleam/erlang/process

pub fn main() {
  wisp.configure_logger()
  
  let assert Ok(conn) = config.get_db_connection()
  
  let secret_key_base = wisp.random_string(64)
  
  let assert Ok(_) =
    {fn(req) { handle_request(req, conn) }}
    |> wisp_mist.handler(secret_key_base)
    |> mist.new
    |> mist.port(3000)
    |> mist.start_http
    
  io.println("Starting server on port 3000")
  process.sleep_forever()
}

pub fn handle_request(req: Request, conn: pgo.Connection) -> Response {
  case req.method, wisp.path_segments(req) {
    Get, [] -> handle_root(conn)
    Get, ["status"] -> handle_status()
    _, _ -> not_found()
  }
}

fn handle_root(conn: pgo.Connection) -> Response {
  case database.add_entry_and_get_count(conn) {
    Ok(#(uuid, count)) -> {
      case database.get_latest_entry(conn) {
        Ok(#(latest_uuid, timestamp)) -> {
          let body = json.object([
            #("message", json.string("This is a simple, basic Gleam / Wisp application running on Zerops.io, each request adds an entry to the PostgreSQL database and returns a count.")),
            #("newEntry", json.string(uuid)),
            #("latestEntry", json.object([
              #("uuid", json.string(latest_uuid)),
              #("timestamp", json.string(timestamp))
            ])),
            #("count", json.int(count))
          ])
          
          wisp.json_response(
            json.to_string_builder(body),
            201
          )
        }
        Error(err) -> 
          wisp.json_response(
            json.to_string_builder(json.object([
              #("error", json.string(err))
            ])),
            500
          )
      }
    }
    Error(err) -> 
      wisp.json_response(
        json.to_string_builder(json.object([
          #("error", json.string(err))
        ])),
        500
      )
  }
}

fn handle_status() -> Response {
  wisp.json_response(
    json.to_string_builder(json.object([
      #("status", json.string("UP"))
    ])),
    200
  )
}
