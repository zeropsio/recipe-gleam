import envoy
import gleam/pgo
import gleam/result

pub fn read_connection_uri() -> Result(pgo.Connection, Nil) {
  use database_url <- result.try(envoy.get("DATABASE_URL"))
  use config <- result.try(pgo.url_config(database_url))
  Ok(pgo.connect(config))
} 
