use Mix.Config

config :faux_banker, FauxBankerWeb.Endpoint,
  http: [port: 22_000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    node: [
      "node_modules/brunch/bin/brunch",
      "watch",
      "--stdin",
      cd: Path.expand("../assets", __DIR__)
    ]
  ]

config :faux_banker, FauxBankerWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{lib/faux_banker_web/views/.*(ex)$},
      ~r{lib/faux_banker_web/templates/.*(eex)$}
    ]
  ]

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20

config :faux_banker, FauxBanker.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "faux_user",
  password: "faux1234",
  database: "faux_dev",
  hostname: "localhost",
  pool_size: 10

config :faux_banker, FauxBanker.LogRepo,
  adapter: Mongo.Ecto,
  database: "faux_log_dev",
  hostname: "localhost",
  pool_size: 10

config :eventstore, EventStore.Storage,
  serializer: Commanded.Serialization.JsonSerializer,
  username: "faux_user",
  password: "faux1234",
  database: "faux_eventstore_dev",
  hostname: "localhost",
  pool_size: 10
