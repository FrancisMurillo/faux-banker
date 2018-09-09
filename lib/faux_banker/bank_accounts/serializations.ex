defimpl Commanded.Serialization.JsonDecoder,
  for: FauxBanker.BankAccounts.Accounts.Events.AccountOpened do
  @moduledoc nil

  alias Decimal

  alias FauxBanker.BankAccounts.Accounts.Events.AccountOpened, as: Event

  def decode(%Event{balance: balance} = state),
    do: %Event{state | balance: Decimal.new(balance)}
end

defimpl Commanded.Serialization.JsonDecoder,
  for: FauxBanker.BankAccounts.Accounts.Events.AmountWithdrawn do
  @moduledoc nil

  alias Decimal

  alias FauxBanker.BankAccounts.Accounts.Events.AmountWithdrawn, as: Event

  def decode(%Event{balance: balance, amount: amount} = state),
    do: %Event{
      state
      | balance: Decimal.new(balance),
        amount: Decimal.new(amount)
    }
end

defimpl Commanded.Serialization.JsonDecoder,
  for: FauxBanker.BankAccounts.Accounts.Events.AmountDeposited do
  @moduledoc nil

  alias Decimal

  alias FauxBanker.BankAccounts.Accounts.Events.AmountDeposited, as: Event

  def decode(%Event{balance: balance, amount: amount} = state),
    do: %Event{
      state
      | balance: Decimal.new(balance),
        amount: Decimal.new(amount)
    }
end

defimpl Commanded.Serialization.JsonDecoder,
  for: FauxBanker.BankAccounts.Accounts.Events.AmountTransferred do
  @moduledoc nil

  alias Decimal

  alias FauxBanker.BankAccounts.Accounts.Events.AmountTransferred, as: Event

  def decode(
        %Event{
          amount: amount,
          balance: balance,
          previous_balance: previous_balance
        } = state
      ),
      do: %Event{
        state
        | amount: Decimal.new(amount),
          balance: Decimal.new(balance),
          previous_balance: Decimal.new(previous_balance)
      }
end

defimpl Commanded.Serialization.JsonDecoder,
  for: FauxBanker.BankAccounts.Accounts.Events.AmountReceived do
  @moduledoc nil

  alias Decimal

  alias FauxBanker.BankAccounts.Accounts.Events.AmountReceived, as: Event

  def decode(
        %Event{
          amount: amount,
          balance: balance,
          previous_balance: previous_balance
        } = state
      ),
      do: %Event{
        state
        | amount: Decimal.new(amount),
          balance: Decimal.new(balance),
          previous_balance: Decimal.new(previous_balance)
      }
end

defimpl Commanded.Serialization.JsonDecoder,
  for: FauxBanker.BankAccounts.Accounts.Aggregates do
  @moduledoc nil

  alias Decimal

  alias FauxBanker.BankAccounts.Accounts.Aggregates, as: State

  def decode(%State{balance: balance} = state),
    do: %State{state | balance: Decimal.new(balance)}
end
