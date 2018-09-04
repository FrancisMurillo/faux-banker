defmodule FauxBanker.BankAccounts.BankAccount do
  @moduledoc nil

  alias __MODULE__, as: Entity

  use Ecto.Schema

  import Ecto.Changeset
  # alias FauxBanker.Randomizer

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

  def open_account_changeset(%Entity{} = account) do
    account
    |> cast(attrs, [
      :name,
      :description,
      :balance
    ])
    |> unique_constraint(:name)
  end
end
