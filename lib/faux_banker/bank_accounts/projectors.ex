defmodule FauxBanker.BankAccounts.Projectors do
  @moduledoc nil

  defmodule AccountManager do
    @moduledoc nil

    use Commanded.Projections.Ecto,
      name: "BankAccounts.AccountManager",
      consistency: :strong

    alias Ecto.{Changeset, Multi}

    alias FauxBanker.Repo

    alias FauxBanker.Clients.Client

    alias FauxBanker.BankAccounts, as: Context
    alias Context.BankAccount, as: Entity

    alias Context.Accounts.Events.{
      AccountOpened
    }

    def error({:error, %Changeset{}}, _event, _context),
      do: :skip

    project %AccountOpened{
              id: id,
              client_id: client_id,
              code: code,
              name: name,
              description: description,
              balance: balance
            } = event do
      client = Repo.get!(Client, client_id)

      multi
      |> Multi.insert(
        :account,
        Entity.open_account_changeset(
          %Entity{id: id},
          client,
          %{code: code, name: name, description: description, balance: balance}
        )
      )
    end
  end
end
