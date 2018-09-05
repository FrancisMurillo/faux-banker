defmodule FauxBanker.AccountRequests.Supervisor do
  @moduledoc nil

  alias FauxBanker.AccountRequests, as: Context

  use Supervisor

  def start_link(), do: Supervisor.start_link(__MODULE__, [], name: __MODULE__)

  def init(_arg),
    do:
      Supervisor.init(
        [
          Context.Projectors.RequestManager,
          Context.ProcessManagers.MailSaga
        ],
        strategy: :one_for_one
      )
end
