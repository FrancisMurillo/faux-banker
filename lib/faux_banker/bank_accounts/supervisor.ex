defmodule FauxBanker.BankAccounts.Supervisor do
  alias FauxBanker.BankAccounts, as: Context

  use Supervisor

  def start_link(), do: Supervisor.start_link(__MODULE__, [], name: __MODULE__)

  def init(_arg),
    do:
      Supervisor.init(
        [
          Context.Projectors.AccountManager,
          Context.Projectors.LogManager
        ],
        strategy: :one_for_one
      )
end
