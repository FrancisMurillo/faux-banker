defmodule FauxBanker.BankAccounts do
  @moduledoc false

  alias __MODULE__, as: Context
  alias Context.Accounts, as: AccountContext

  # alias Ecto.Changeset
  alias UUID

  alias FauxBanker.{Repo, Router}

  alias Context.BankAccount

  alias AccountContext.Commands.{OpenAccount}

  defmodule Queries do
    @moduledoc false

    import Ecto.Query, warn: false

    def select_accounts_by_client_id(client_id),
      do: from(b in BankAccount, where: b.client_id == ^client_id)
  end

  def list_accounts_by_client_id(client_id) do
    client_id |> Context.Queries.select_accounts_by_client_id() |> Repo.all()
  end

  def open_client_account(client, attrs) do
    id = UUID.uuid4()

    %OpenAccount{id: id}
    |> OpenAccount.changeset(client, attrs)
    |> Router.dispatch()
    |> case do
      :ok ->
        account = Repo.get!(BankAccount, id)
        {:ok, account}

      error ->
        error
    end
  end
end
