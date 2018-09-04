defmodule FauxBanker.BankAccounts.Accounts.Commands do
  @moduledoc nil

  defmodule OpenAccount do
    @moduledoc nil

    alias __MODULE__, as: Command

    import Ecto.Changeset
    alias UUID

    alias FauxBanker.Support.Randomizer

    alias FauxBanker.Clients.Client

    defstruct [:id, :client_id, :code, :name, :description, :initial_balance]

    use ExConstructor

    @schema %{
      id: :binary_id,
      client_id: :binary_id,
      code: :string,
      name: :string,
      description: :string,
      initial_balance: :decimal
    }

    @form_fields [:name, :description, :initial_balance]

    def changeset(%Command{} = command, %Client{id: client_id}, attrs) do
      {command, @schema}
      |> cast(attrs, @form_fields)
      |> validate_required(@form_fields -- [:description])
      |> validate_number(:initial_balance, greater_than: Decimal.new(0))
      |> force_change(:client_id, client_id)
      |> (fn changeset ->
            if get_field(changeset, :id) do
              changeset
            else
              force_change(changeset, :id, UUID.uuid4())
            end
          end).()
      |> (fn changeset ->
            if get_field(changeset, :code) do
              changeset
            else
              force_change(changeset, :code, Randomizer.randomizer(6, :upcase))
            end
          end).()
    end
  end

  defmodule WithdrawAmount do
    @moduledoc nil

    alias __MODULE__, as: Command

    import Ecto.Changeset

    alias FauxBanker.BankAccounts.BankAccount

    defstruct [:id, :amount, :description]

    use ExConstructor

    @schema %{
      id: :binary_id,
      amount: :decimal,
      description: :string
    }

    @form_fields [:amount, :description]

    def changeset(%Command{} = command, %BankAccount{id: id}, attrs) do
      {command, @schema}
      |> cast(attrs, [:id] ++ @form_fields)
      |> force_change(:id, id)
      |> validate_required(@form_fields -- [:description])
      |> validate_number(:amount, greater_than: Decimal.new(0))
    end
  end

  defmodule DepositAmount do
    @moduledoc nil

    alias __MODULE__, as: Command

    import Ecto.Changeset

    alias FauxBanker.BankAccounts.BankAccount

    defstruct [:id, :amount, :description]

    use ExConstructor

    @schema %{
      id: :binary_id,
      amount: :decimal,
      description: :string
    }

    @form_fields [:amount, :description]

    def changeset(%Command{} = command, %BankAccount{id: id}, attrs) do
      {command, @schema}
      |> cast(attrs, [:id] ++ @form_fields)
      |> force_change(:id, id)
      |> validate_required(@form_fields -- [:description])
      |> validate_number(:amount, greater_than: Decimal.new(0))
    end
  end
end

defmodule FauxBanker.BankAccounts.Accounts.Events do
  @moduledoc nil
  defmodule AccountOpened do
    @moduledoc nil
    @derive [Poison.Encoder]
    defstruct [:id, :client_id, :code, :name, :description, :balance]
  end

  defmodule AmountWithdrawn do
    @moduledoc nil
    @derive [Poison.Encoder]
    defstruct [:id, :amount, :description, :balance]
  end

  defmodule AmountDeposited do
    @moduledoc nil
    @derive [Poison.Encoder]
    defstruct [:id, :amount, :description, :balance]
  end
end

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
