use Mix.Config

config :faux_banker, FauxBankerWeb.Endpoint,
  http: [port: 4001],
  server: false

config :logger, level: :warn

config :faux_banker, FauxBanker.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "faux_user",
  password: "faux_user",
  database: "faux_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :faux_banker, FauxBanker.LogRepo,
  adapter: Mongo.Ecto,
  database: "faux_log_test",
  username: "mongodb",
  password: "mongodb",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :commanded,
  event_store_adapter: Commanded.EventStore.Adapters.InMemory,
  dispatch_consistency_timeout: 5_000,
  assert_receive_event_timeout: 5_000

config :eventstore, EventStore.Storage,
  serializer: EventStore.TermSerializer,
  username: "faux_user",
  password: "faux_user",
  database: "faux_eventstore_test",
  hostname: "localhost",
  pool_size: 10,
  pool_overflow: 5

config :bcrypt_elixir, log_rounds: 4
