# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :line98,
  ecto_repos: [Line98.Repo]

# Configures the endpoint
config :line98, Line98Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "LPx0HL8WrfB6kfC0ViwA+7PX1DFYuwCvhQsopncwIzOFi4lxJ/IJUIeQsv/v7yko",
  render_errors: [view: Line98Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Line98.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
    signing_salt: "glRxfX9vv16FsTc10K78wtK6C7ZO7Qe8"
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
