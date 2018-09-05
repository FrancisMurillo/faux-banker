defmodule FauxBanker.Repo.Migrations.CreateAccountRequests do
  use Ecto.Migration

  def change do
    create table(:account_requests, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:code, :string)
      add(:amount, :decimal, precision: 15, scale: 4)
      add(:sender_reason, :string)
      add(:receipient_reason, :string, null: true)
      add(:status, :integer)

      add(:sender_id, references(:users, column: :id, type: :binary_id))
      add(:receipient_id, references(:users, column: :id, type: :binary_id))

      add(
        :sender_account_id,
        references(:bank_accounts, column: :id, type: :binary_id)
      )

      add(
        :receipient_account_id,
        references(:bank_accounts, column: :id, type: :binary_id)
      )

      timestamps()
    end

    create(unique_index(:account_requests, [:code]))
  end
end
