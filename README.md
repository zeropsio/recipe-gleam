# Zerops x Gleam
This is a minimalist example of a Gleam application running on [Zerops](https://zerops.io) — as few libraries as possible, just a simple endpoint with connnect, read and write to a Zerops PostgreSQL database.

![gleam](https://github.com/zeropsio/recipe-shared-assets/blob/main/covers/svg/cover-gleam.svg)

<br />

## Deploy on Zerops
You can either click the deploy button to deploy directly on Zerops, or manually copy the [import yaml](https://github.com/zeropsio/recipe-gleam/blob/main/zerops-project-import.yml) to the import dialog in the Zerops app.

[![Deploy on Zerops](https://github.com/zeropsio/recipe-shared-assets/blob/main/deploy-button/green/deploy-button.svg)](https://app.zerops.io/recipe/gleam)

<br/>

## Recipe features
- Gleam web application running on a load balanced **Zerops Gleam** service
- Zerops **PostgreSQL 16** service as database
- Built with `wisp` and `mist` for HTTP server functionality
- Health check endpoint at `/status`
- Utilization of Zerops' built-in **environment variables** system
- Utilization of Zerops' built-in **log management**

<br/>

## Project Structure
