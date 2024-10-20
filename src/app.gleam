import mist
import gleam/erlang/process
import gleam/bytes_builder
import gleam/http/response.{Response}
import gleam/string
import gleam/io
import gleam/int
import gleam/erlang/os
import gleam/result
import config

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
  // Check database connection using config
  let db_status = case config.read_connection_uri() {
    Ok(_) -> "Database connection successful! ✅"
    Error(_) -> "Database connection failed! ❌"
  }

  let body = bytes_builder.from_string(
    "<!DOCTYPE html>
    <html>
    <head>
      <meta charset=\"UTF-8\">
      <title>Gleam Mist Application on Zerops</title>
      <style>
        body {
          font-family: Arial, sans-serif;
          max-width: 800px;
          margin: 20px auto;
          padding: 0 20px;
        }
        .status {
          padding: 10px;
          margin: 10px 0;
          border-radius: 4px;
        }
        .success {
          background-color: #e6ffe6;
          border: 1px solid #00cc00;
        }
        .error {
          background-color: #ffe6e6;
          border: 1px solid #cc0000;
        }
      </style>
    </head>
    <body>
      <h1>Gleam Mist Application</h1>
      <div class=\"status " <> case config.read_connection_uri() {
        Ok(_) -> "success"
        Error(_) -> "error"
      } <> "\">
        " <> db_status <> "
      </div>
      <p>This is a simple, basic Gleam mist application running on Zerops.io, each request adds an entry to the PostgreSQL database and returns a count.</p>
      <p>See the <a href='https://github.com/zeropsio/recipe-gleam' target='_blank'> source repository </a> for more information.</p>
    </body>
    </html>"
  )

  Response(200, [#("Content-Type", "text/html")], mist.Bytes(body))
}
