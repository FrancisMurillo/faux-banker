defmodule FauxBanker.Clients.Client do
  @moduledoc nil

  use Ecto.Schema

  alias FauxBanker.BankAccounts.BankAccount

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field(:code, :string)
    field(:username, :string, null: true)
    field(:email, :string)
    field(:first_name, :string, null: true)
    field(:last_name, :string, null: true)
    field(:phone_number, :string, null: true)

    has_many(
      :accounts,
      BankAccount,
      foreign_key: :client_id,
      references: :id
    )

    field(:role, FauxBanker.Enums.Role)
    timestamps()
  end
end
