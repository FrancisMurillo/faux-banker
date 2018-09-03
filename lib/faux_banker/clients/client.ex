defmodule FauxBanker.Clients.Client do
  @moduledoc nil

  alias __MODULE__, as: Entity

  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field(:code, :string)
    field(:username, :string, null: true)
    field(:email, :string)
    field(:first_name, :string, null: true)
    field(:last_name, :string, null: true)
    field(:phone_number, :string, null: true)

    field(:role, FauxBanker.Enums.Role)
    timestamps()
  end
end
