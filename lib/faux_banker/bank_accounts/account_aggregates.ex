defmodule FauxBanker.BankAccounts.Accounts.Aggregates do
  @moduledoc nil

  alias __MODULE__, as: State
  alias FauxBanker.BankAccounts, as: Context
  alias Context.Accounts, as: AccountSubContext

  alias Decimal

  alias AccountSubContext.Commands.{OpenAccount, WithdrawAmount, DepositAmount}

  alias AccountSubContext.Events.{
    AccountOpened,
    AmountWithdrawn,
    AmountDeposited
  }

  defstruct [:id, :balance]

  if Mix.env() != :prod do
    def execute(_state, %State{} = new_state),
      do: new_state

    def apply(_state, %State{} = new_state),
      do: new_state
  end

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

  def execute(%State{balance: balance}, %WithdrawAmount{
        id: id,
        description: description,
        amount: amount
      }) do
    if Decimal.cmp(amount, balance) == :gt do
      {:error, :invalid_amount}
    else
      %AmountWithdrawn{
        id: id,
        description: description,
        amount: amount,
        balance: Decimal.sub(balance, amount)
      }
    end
  end

  def execute(%State{balance: balance}, %DepositAmount{
        id: id,
        description: description,
        amount: amount
      }),
      do: %AmountDeposited{
        id: id,
        description: description,
        amount: amount,
        balance: Decimal.add(balance, amount)
      }

  def apply(_state, %AccountOpened{id: id, balance: balance}),
    do: %State{id: id, balance: balance}

  def apply(state, %AmountWithdrawn{balance: balance}),
    do: %{state | balance: balance}

  def apply(state, %AmountDeposited{balance: balance}),
    do: %{state | balance: balance}
end

defimpl Poison.Encoder, for: Decimal do
  def encode(value, options) do
    value |> Decimal.to_float() |> Poison.encode!(options)
  end
end

defimpl Commanded.Serialization.JsonDecoder,
  for: FauxBanker.BankAccounts.Accounts.Aggregates do
  @moduledoc nil

  alias Decimal

  alias FauxBanker.BankAccounts.Accounts.Aggregates, as: State

  def decode(%State{balance: balance} = state),
    do: %State{state | balance: Decimal.new(balance)}
end

defmodule FauxBanker.BankAccounts.Accounts.Router do
  use Commanded.Commands.Router

  alias FauxBanker.BankAccounts, as: Context
  alias Context.Accounts, as: AccountSubContext

  alias AccountSubContext.Commands.{OpenAccount, WithdrawAmount, DepositAmount}

  alias AccountSubContext.Aggregates, as: State

  identify(State, by: :id, prefix: "bank-account-")

  if Mix.env() != :prod do
    dispatch(State, to: State)
  end

  dispatch(
    [
      OpenAccount,
      WithdrawAmount,
      DepositAmount
    ],
    to: State
  )
end
