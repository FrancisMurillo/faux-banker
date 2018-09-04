defmodule FauxBanker.BankAccounts.Accounts.Aggregates do
  @moduledoc nil

  alias __MODULE__, as: State
  alias FauxBanker.BankAccounts, as: Context
  alias Context.Accounts, as: AccountSubContext

  alias AccountSubContext.Commands.{OpenAccount}

  alias AccountSubContext.Events.{AccountOpened}

  defstruct [:id, :balance]

  def execute(_state, %OpenAccount{id: id, client_id}),
    do: %AccountOpened{}

  def apply(_state, %AccountOpened{}),
    do: %State{}
end

defmodule FauxBanker.BankAccounts.Accounts.Router do
  use Commanded.Commands.Router

  alias FauxBanker.BankAccounts, as: Context
  alias Context.Accounts, as: AccountSubContext

  alias AccountSubContext.Commands.{OpenAccount}

  alias AccountSubContext.Aggregates, as: State

  identify(State, by: :id, prefix: "bank-account-")

  middleware(FauxBanker.Support.ChangesetMiddleware)

  if Mix.env() == :test do
    dispatch(State, to: State)
  end

  dispatch(
    [
      OpenAccount
    ],
    to: State
  )
end
