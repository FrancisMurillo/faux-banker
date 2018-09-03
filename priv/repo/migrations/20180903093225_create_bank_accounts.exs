defmodule FauxBanker.Repo.Migrations.CreateBankAccounts do
  use Ecto.Migration

  def change do
    create table(:bank_accounts, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:code, :string)
      add(:name, :citext, null: false)
      add(:description, :string)
      add(:balance, :decimal, null: false, precision: 10, scale: 4)

      add(:client_id, references(:users, column: :id, type: :binary_id))
      timestamps()
    end

    create(unique_index(:bank_accounts, [:code]))
    create(unique_index(:bank_accounts, [:name]))
  end
end
