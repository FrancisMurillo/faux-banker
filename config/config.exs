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
  base_path: "/auth",
  providers: [
    identity:
      {Ueberauth.Strategy.Identity,
       [
         callback_methods: ["POST"]
       ]}
  ]

config :faux_banker, FauxBanker.Guardian,
  allowed_algos: ["HS512"],
  issuer: "faux_banker",
  secret_key:
    "4/hIFod6yIPz2OqsjS1NyX9m2H/dx2DC2MvGEySb/0aNa8nwShAvxyMkbadswpbI",
  token_module: Guardian.Token.Jwt,
  error_handler: FauxBankerWeb.AuthErrorHandler

config :commanded,
  event_store_adapter: Commanded.EventStore.Adapters.EventStore

config :commanded_ecto_projections,
  repo: FauxBanker.Repo

import_config "#{Mix.env()}.exs"
