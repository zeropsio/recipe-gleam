import envoy
import gleam/pgo
import gleam/result
import gleam/io

pub fn read_connection_uri() -> Result(pgo.Connection, Nil) {
  io.println("Attempting to connect to database...")
  
  use database_url <- result.try({
    case envoy.get("DATABASE_URL") {
      Ok(url) -> {
        io.println("Found DATABASE_URL configuration")
        Ok(url)
      }
      Error(_) -> {
        io.println("Failed to get DATABASE_URL")
        Error(Nil)
      }
    }
  })

  use config <- result.try({
    case pgo.url_config(database_url) {
      Ok(cfg) -> {
        io.println("Database configuration parsed successfully")
        Ok(cfg)
      }
      Error(_) -> {
        io.println("Failed to parse database configuration")
        Error(Nil)
      }
    }
  })

  case pgo.connect(config) {
    connection -> {
      io.println("Successfully connected to database! ✨")
      Ok(connection)
    }
  }
}
