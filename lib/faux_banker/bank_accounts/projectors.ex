defmodule FauxBanker.BankAccounts.Projectors do
  @moduledoc nil

  defmodule BankAccountManager do
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
      do: {:skip, :continue_pending}

    project %AccountOpened{id: id, client_id: client_id} = event do
      client = Repo.get!(Client, client_id)

      multi
      |> Multi.insert(
        :account,
        Entity.open_account_changeset(
          %Entity{id: id},
          client,
          Map.from_struct(event)
        )
      )
    end
  end
end
