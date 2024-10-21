import mist
import gleam/erlang/process
import gleam/bytes_builder
import gleam/http/response.{Response}
import gleam/string
import gleam/io
import gleam/int
import gleam/erlang/os
import gleam/result
import glenvy/dotenv
import glenvy/env
import database
import config

pub fn main() {
  // Load and verify environment variables at startup
  case dotenv.load() {
Ok(_) -> {
  io.println("Environment variables loaded")
  case env.get_string("DATABASE_URL") {
    Ok(_) -> io.println("DATABASE_URL is set")
    Error(_) -> io.println("DATABASE_URL is not set")
  }
}
    Error(_) -> {
      io.println("Failed to load environment variables: ")
    }
  }
  
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
  io.println("Received a new request")
  
  // Check database connection using config
  let #(db_status, entry_count) = case config.get_db_connection() {
    Ok(connection) -> {
      io.println("Database connection successful")
      // Use the database module to add entry and get count
      case database.add_entry_and_get_count(connection) {
        Ok(count) -> {
          io.println("Successfully added entry and got count: " <> int.to_string(count))
          #("Database connection successful! ✅", count)
        }
        Error(err) -> {
          io.println("Database operation failed: " <> err)
          #("Database operation failed: " <> err, 0)
        }
      }
    }
    Error(err) -> {
      let error_message = case err {
        Nil -> "Unknown database connection error"
      }
      io.println(error_message)
      #(error_message <> " ❌", 0)
    }
  }
  
  io.println("Preparing response")
  
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
        .count {
          font-size: 24px;
          font-weight: bold;
          margin: 20px 0;
        }
      </style>
    </head>
    <body>
      <h1>Gleam Mist Application</h1>
      <div class=\"status " <> case string.contains(db_status, "successful") {
        True -> "success"
        False -> "error"
      } <> "\">
        " <> db_status <> "
      </div>
      <div class=\"count\">
        Total entries: " <> int.to_string(entry_count) <> "
      </div>
      <p>This is a simple, basic Gleam mist application running on Zerops.io, each request adds an entry to the PostgreSQL database and returns a count.</p>
      <p>See the <a href='https://github.com/zeropsio/recipe-gleam' target='_blank'> source repository </a> for more information.</p>
    </body>
    </html>"
  )
  
  io.println("Sending response")
  Response(200, [#("Content-Type", "text/html")], mist.Bytes(body))
}
