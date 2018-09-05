defmodule FauxBanker.AccountRequests.AccountRequest do
  @moduledoc nil

  alias __MODULE__, as: Entity

  use Ecto.Schema

  import Ecto.Changeset

  alias FauxBanker.Repo

  alias FauxBanker.BankAccounts.BankAccount
  alias FauxBanker.Clients.Client

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "account_requests" do
    field(:code, :string)
    field(:amount, :decimal)
    field(:sender_reason, :string)
    field(:receipient_reason, :string, null: true)
    field(:status, FauxBanker.Enums.RequestStatus)

    belongs_to(
      :sender,
      Client,
      foreign_key: :sender_id,
      references: :id,
      type: :binary_id
    )

    belongs_to(
      :sender_account,
      BankAccount,
      foreign_key: :sender_account_id,
      references: :id,
      type: :binary_id
    )

    belongs_to(
      :receipient,
      Client,
      foreign_key: :receipient_id,
      references: :id,
      type: :binary_id
    )

    belongs_to(
      :receipient_account,
      BankAccount,
      foreign_key: :receipient_account_id,
      references: :id,
      type: :binary_id
    )

    timestamps()
  end

  @required_fields [
    :code,
    :amount,
    :sender_reason
  ]

  @doc false
  def changeset(%Entity{} = request, attrs) do
    request
    |> cast(attrs, @required_fields)
    |> unique_constraint(:code)
  end

  @doc false
  def make_request_changeset(
        %Entity{} = request,
        %Client{} = sender,
        %BankAccount{} = sender_account,
        %Client{} = receipient,
        attrs
      ) do
    request
    |> cast(attrs, [:id] ++ @required_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:code)
    |> force_change(:status, :pending)
    |> put_assoc(:sender, sender)
    |> put_assoc(:sender_account, sender_account)
    |> put_assoc(:receipient, receipient)
  end

  def approve_request_changeset(
        %Entity{} = request,
        %BankAccount{} = receipient_account,
        attrs
      ) do
    request
    |> Repo.preload([:receipient_account])
    |> cast(attrs, [:receipient_reason])
    |> validate_required([:receipient_reason])
    |> force_change(:status, :approved)
    |> put_assoc(:receipient_account, receipient_account)
  end

  def reject_request_changeset(
        %Entity{} = request,
        attrs
      ) do
    request
    |> cast(attrs, [:receipient_reason])
    |> validate_required([:receipient_reason])
    |> force_change(:status, :rejected)
  end
end
