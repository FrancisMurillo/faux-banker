defmodule FauxBanker.BankAccounts.Accounts.Aggregates do
  @moduledoc nil

  alias __MODULE__, as: State
  alias FauxBanker.BankAccounts, as: Context
  alias Context.Accounts, as: AccountSubContext

  alias AccountSubContext.Commands.{OpenAccount}

  alias AccountSubContext.Events.{AccountOpened}

  defstruct [:code, :balance]

  def execute(
        _state,
        %OpenAccount{
          id: id,
          client_id: client_id,
          code: code,
          name: name,
          description: description,
          initial_balance: balance
        }
      ),
      do: %AccountOpened{
        id: id,
        client_id: client_id,
        code: code,
        name: name,
        description: description,
        balance: balance
      }

  def apply(_state, %AccountOpened{code: code, balance: balance}),
    do: %State{code: code, balance: balance}
end

defmodule FauxBanker.BankAccounts.Accounts.Router do
  use Commanded.Commands.Router

  alias FauxBanker.BankAccounts, as: Context
  alias Context.Accounts, as: AccountSubContext

  alias AccountSubContext.Commands.{OpenAccount}

  alias AccountSubContext.Aggregates, as: State

  identify(State, by: :id, prefix: "bank-account-")

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
