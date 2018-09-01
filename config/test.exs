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

config :bcrypt_elixir, log_rounds: 4
