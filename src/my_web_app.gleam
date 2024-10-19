import mist
import gleam/erlang/process
import gleam/bytes_builder
import gleam/http/response.{Response}
import gleam/string
import gleam/io
import gleam/int
import gleam/erlang/os
import gleam/result

pub fn main() {
  let port =
    os.get_env("PORT")
    |> result.then(int.parse)
    |> result.unwrap(3000)

  let assert Ok(_) =
    web_service
    |> mist.new
    |> mist.port(port)
    |> mist.start_http

  ["Started listening on localhost:", int.to_string(port), " ✨"]
  |> string.concat
  |> io.println

  process.sleep_forever()
}

fn web_service(_request) {
  let body = bytes_builder.from_string(
    "This is a simple, basic Gleam mist application running on Zerops.io, each request adds an entry to the PostgreSQL database and returns a count.
    See the source repository (https://github.com/zeropsio/recipe-gleam) for more information."
  )
  Response(200, [], mist.Bytes(body))
}
