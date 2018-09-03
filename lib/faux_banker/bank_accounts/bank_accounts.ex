defmodule FauxBanker.BankAccounts do
  @moduledoc false

  alias __MODULE__, as: Context

  alias Ecto.Changeset

  alias FauxBanker.Repo

  alias Context.BankAccount

  defmodule Queries do
    @moduledoc false

    import Ecto.Query, warn: false

    def select_accounts_by_client_id(client_id),
      do: from(b in BankAccount, where: b.client_id == ^client_id)
  end

  def list_accounts_by_client_id(client_id) do
    client_id |> Context.Queries.select_accounts_by_client_id() |> Repo.all()
  end
end
