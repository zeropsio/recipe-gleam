# Zerops x Gleam
This is the most bare-bones example of Gleam running on [Zerops](https://zerops.io) — as few libraries as possible, just a simple endpoint with connnect, read and write to a Zerops PostgreSQL database.

![gleam](https://github.com/zeropsio/recipe-shared-assets/blob/main/covers/svg/cover-gleam.svg)

<br />

## Deploy on Zerops
You can either click the deploy button to deploy directly on Zerops, or manually copy the [import yaml](https://github.com/zeropsio/recipe-gleam/blob/main/zerops-project-import.yml) to the import dialog in the Zerops app.

[![Deploy on Zerops](https://github.com/zeropsio/recipe-shared-assets/blob/main/deploy-button/green/deploy-button.svg)](https://app.zerops.io/recipe/gleam)

<br/>

## Recipe features
- **Wisp** + **Mist** app running on a load balanced **Zerops Gleam** service
- Zerops **PostgreSQL 16** service as database
- Built with `wisp` and `mist` for HTTP server functionality
- Health check endpoint at `/status`
- Utilization of Zerops' built-in **environment variables** system
- Utilization of Zerops' built-in **log management**

<br/>

## Production vs. development
Base of the recipe is ready for production, the difference comes down to:

- Use highly available version of the PostgreSQL database (change `mode` from `NON_HA` to `HA` in recipe YAML, `db` service section)
- Use at least two containers for the Gleam service to achieve high reliability and resilience (add `minContainers: 2` in recipe YAML, `api` service section)

Futher things to think about when running more complex, highly available Gleam production apps on Zerops:
- containers are volatile - use Zerops object storage to store your files
- use Zerops Redis (Valkey) for caching, storing sessions and pub/sub messaging

<br/>
<br/>

Need help setting your project up? Join [Zerops Discord community](https://discord.com/invite/WDvCZ54).
