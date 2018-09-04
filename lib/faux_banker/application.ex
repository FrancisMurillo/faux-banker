defmodule FauxBanker.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(FauxBanker.Repo, []),
      supervisor(FauxBanker.LogRepo, []),
      supervisor(FauxBankerWeb.Endpoint, []),
      supervisor(FauxBanker.BankAccounts.Supervisor, [])
    ]

    opts = [strategy: :one_for_one, name: FauxBanker.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    FauxBankerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
