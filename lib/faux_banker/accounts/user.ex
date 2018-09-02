defmodule FauxBanker.Accounts.User do
  alias __MODULE__, as: Entity

  use Ecto.Schema

  import Ecto.Changeset
  alias Comeonin.Bcrypt, as: Comeonin

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field(:username, :string, null: true)
    field(:role, FauxBanker.Enums.Role)
    field(:email, :string)
    field(:first_name, :string, null: true)
    field(:last_name, :string, null: true)
    field(:phone_number, :string, null: true)
    field(:password, :string, virtual: true)
    field(:password_hash, :string, null: true)

    timestamps()
  end

  @doc false
  def changeset(%Entity{} = user, attrs) do
    user
    |> cast(attrs, [
      :id,
      :username,
      :role,
      :email,
      :first_name,
      :last_name,
      :phone_number,
      :password
    ])
    |> unique_constraint(:username)
    |> unique_constraint(:email)
  end

  def register_client_changeset(%Entity{} = user, attrs) do
    fields = [
      :username,
      :email,
      :first_name,
      :last_name,
      :phone_number,
      :password
    ]

    user
    |> cast(attrs, fields)
    |> validate_required(fields)
    |> unique_constraint(:username)
    |> unique_constraint(:email)
    |> prepare_changes(fn changeset ->
      password_hash =
        changeset
        |> get_change(:password, "")
        |> Comeonin.hashpwsalt()

      changeset
      |> put_change(:password_hash, password_hash)
      |> cast(%{role: :client}, [:role])
    end)
  end
end
