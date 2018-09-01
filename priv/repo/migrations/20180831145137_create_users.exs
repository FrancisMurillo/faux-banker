defmodule FauxBanker.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:username, :citext, null: true)
      add(:email, :citext, null: false)
      add(:role, :integer)
      add(:first_name, :citext, null: true)
      add(:last_name, :citext, null: true)
      add(:phone_number, :string, null: true)
      add(:password_hash, :string, null: true)

      timestamps()
    end

    create(unique_index(:users, [:username], where: "username IS NOT NULL"))
    create(unique_index(:users, [:email]))
  end
end
