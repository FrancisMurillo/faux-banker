defmodule FauxBanker.BankAccounts.BankAccount do
  @moduledoc nil

  alias __MODULE__, as: Entity

  use Ecto.Schema

  import Ecto.Changeset
  # alias FauxBanker.Support.Randomizer

  alias FauxBanker.Clients.Client

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "bank_accounts" do
    field(:code, :string)
    field(:name, :string)
    field(:description, :string, null: true)
    field(:balance, :decimal)

    belongs_to(
      :client,
      Client,
      foreign_key: :client_id,
      references: :id,
      type: :binary_id
    )

    timestamps()
  end

  @required_fields [
    :code,
    :name,
    :description,
    :balance
  ]

  @doc false
  def changeset(%Entity{} = account, attrs) do
    account
    |> cast(attrs, [
      :id,
      :code,
      :name,
      :description,
      :balance
    ])
    |> unique_constraint(:code)
    |> unique_constraint(:name)
  end

  def open_account_changeset(%Entity{} = account, %Client{} = client, attrs) do
    account
    |> cast(attrs, [:id] ++ @required_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:code)
    |> unique_constraint(:name)
    |> put_assoc(:client, client)
  end
end
