defmodule FauxBanker.BankAccounts do
  @moduledoc false

  alias __MODULE__, as: Context
  alias Context.Accounts, as: AccountContext

  import Ecto.Changeset
  alias Ecto.Changeset
  alias UUID

  alias FauxBanker.{Repo, Router}

  alias Context.BankAccount

  alias AccountContext.Commands.{OpenAccount, WithdrawAmount, DepositAmount}

  defmodule Queries do
    @moduledoc false

    import Ecto.Query, warn: false

    def select_accounts_by_client_id(client_id),
      do: from(b in BankAccount, where: b.client_id == ^client_id)
  end

  def get_account_by_code(code),
    do: BankAccount |> Repo.get_by(code: code)

  def list_accounts_by_client_id(client_id),
    do:
      client_id |> Context.Queries.select_accounts_by_client_id() |> Repo.all()

  def open_client_account(client, attrs) do
    id = UUID.uuid4()

    case OpenAccount.changeset(%OpenAccount{id: id}, client, attrs) do
      %Changeset{valid?: false} = changeset ->
        {:error, changeset}

      changeset ->
        command = apply_changes(changeset)

        case Router.dispatch(command) do
          :ok ->
            if account = Repo.get(BankAccount, id) do
              {:ok, account}
            else
              {:error, changeset}
            end

          error ->
            error
        end
    end
  end

  def withdraw_from_account(%BankAccount{} = account, attrs) do
    case WithdrawAmount.changeset(%WithdrawAmount{}, account, attrs) do
      %Changeset{valid?: false} = changeset ->
        {:error, changeset}

      changeset ->
        command = apply_changes(changeset)

        case Router.dispatch(command) do
          :ok ->
            {:ok, account}

          error ->
            error
        end
    end
  end

  def deposit_to_account(%BankAccount{} = account, attrs) do
    case DepositAmount.changeset(%DepositAmount{}, account, attrs) do
      %Changeset{valid?: false} = changeset ->
        {:error, changeset}

      changeset ->
        command = apply_changes(changeset)

        case Router.dispatch(command) do
          :ok ->
            {:ok, account}

          error ->
            error
        end
    end
  end
end
