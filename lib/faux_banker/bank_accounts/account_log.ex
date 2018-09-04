defmodule FauxBanker.BankAccounts.AccountLog do
  @moduledoc nil

  alias __MODULE__, as: Entity

  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "account_logs" do
    field(:event, :string)
    field(:code, :string)
    field(:current_balance, :float)
    field(:next_balance, :float)
    field(:logged_at, :utc_datetime)
  end

  @required_fields [
    :event,
    :code,
    :current_balance,
    :next_balance,
    :logged_at
  ]

  @doc false
  def changeset(%Entity{} = account, attrs) do
    account
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end
