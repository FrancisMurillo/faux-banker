# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :faux_banker,
  ecto_repos: [FauxBanker.Repo]

# Configures the endpoint
config :faux_banker, FauxBankerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base:
    "Gy3x9XZnXCWE27QqkoaA0LFYGaBAQUsP3k6D38A9N4nxrGYtO0KI3bQcq2W9X0DU",
  render_errors: [view: FauxBankerWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: FauxBanker.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
