use Mix.Config

config :faux_banker,
  ecto_repos: [FauxBanker.Repo]

config :faux_banker, FauxBankerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base:
    "Gy3x9XZnXCWE27QqkoaA0LFYGaBAQUsP3k6D38A9N4nxrGYtO0KI3bQcq2W9X0DU",
  render_errors: [view: FauxBankerWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: FauxBanker.PubSub, adapter: Phoenix.PubSub.PG2]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

config :ueberauth, Ueberauth,
  providers: [
    identity:
      {Ueberauth.Strategy.Identity,
       [
         callback_methods: ["POST"]
       ]}
  ]

import_config "#{Mix.env()}.exs"
