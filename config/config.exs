# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :sink,
  ecto_repos: [Sink.Repo]

# Configures the endpoint
config :sink, SinkWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "ulHRsDg6UO6E2LWO2r7mXtBEuiNFiSdfonNdMF6In21I+wlS2O2CwsaGLn+2ZpXH",
  render_errors: [view: SinkWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Sink.PubSub,
  live_view: [signing_salt: "g4lXl/Hc"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
