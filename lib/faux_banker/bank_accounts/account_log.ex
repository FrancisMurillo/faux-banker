defmodule FauxBanker.BankAccounts.AccountLog do
  @moduledoc nil

  alias __MODULE__, as: Entity

  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "account_logs" do
    field(:event, :string)
    field(:code, :string)
    field(:request_code, :string, null: true)
    field(:description, :string)
    field(:amount, :float)
    field(:current_balance, :float)
    field(:next_balance, :float)
    field(:logged_at, :utc_datetime)
  end

  @fields [
    :event,
    :code,
    :request_code,
    :description,
    :amount,
    :current_balance,
    :next_balance,
    :logged_at
  ]

  @doc false
  def changeset(%Entity{} = account, attrs) do
    account
    |> cast(attrs, @fields)
    |> validate_required(
      @fields --
        [:request_code, :description, :amount, :current_balance, :next_balance]
    )
  end
end
