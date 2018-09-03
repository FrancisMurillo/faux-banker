defmodule FauxBanker.BankAccounts.Aggregates do
  @moduledoc nil

  alias __MODULE__, as: State
  alias FauxBanker.BankAccounts, as: Context

  alias Context.Commands.{OpenAccount}

  alias Context.Events.{AccountOpened}

  defstruct []

  def execute(_state, %OpenAccount{}),
    do: %AccountOpened{}

  def apply(_state, %AccountOpened{}),
    do: %State{}
end

defmodule FauxBanker.BankAccounts.Router do
  use Commanded.Commands.Router

  alias FauxBanker.BankAccounts, as: Context

  alias Context.Commands.{OpenAccount}

  alias Context.Aggregates, as: State

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
