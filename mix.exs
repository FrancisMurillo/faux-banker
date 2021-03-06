defmodule FauxBanker.Mixfile do
  use Mix.Project

  def project do
    [
      app: :faux_banker,
      version: "0.0.1",
      elixir: "~> 1.6",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [
      mod: {FauxBanker.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:prod), do: ["lib"]
  defp elixirc_paths(_), do: ["lib", "test/support", "support"]

  defp deps do
    [
      {:bamboo, "~> 0.8.0", override: true},
      {:bcrypt_elixir, "~> 1.0"},
      {:credo, "~> 0.10.0", only: [:dev, :test], runtime: false},
      {:comeonin, "~> 4.0"},
      {:eventstore, "~> 0.15.0", override: true},
      {:commanded, "~> 0.17"},
      {:commanded_eventstore_adapter, "~> 0.4"},
      {:commanded_ecto_projections, "~> 0.6"},
      {:ecto_enum, "~> 1.0"},
      {:exconstructor, "~> 1.1.0"},
      {:ex_machina, "~> 2.2"},
      {:faker, "~> 0.10"},
      {:guardian, "~> 1.0"},
      {:mongodb_ecto, "~> 0.2"},
      {:phoenix, "~> 1.3.4"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.2"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:timex, "~> 3.0"},
      {:ueberauth, "~> 0.4"},
      {:ueberauth_identity, "~> 0.2"},
      {:uuid, "~> 1.1"},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"}
    ]
  end

  defp aliases do
    [
      "ecto.setup": [
        "ecto.create",
        "ecto.migrate",
        "run priv/repo/seeds.exs --no-start"
      ],
      "ecto.drop": ["ecto.drop", "event_store.drop"],
      "ecto.create": ["ecto.create", "event_store.create", "event_store.init"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test --no-start"]
    ]
  end
end
