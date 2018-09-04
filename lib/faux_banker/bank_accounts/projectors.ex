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
      AccountOpened,
      AmountWithdrawn,
      AmountDeposited
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
    } do
      client = Repo.get!(Client, client_id)

      multi
      |> Multi.insert(
        :account,
        %Entity{id: id}
        |> Entity.open_account_changeset(
          client,
          %{code: code, name: name, description: description, balance: balance}
        )
      )
    end

    project %AmountWithdrawn{
      id: id,
      balance: balance
    } do
      multi
      |> Multi.update(
        :account,
        Entity
        |> Repo.get!(id)
        |> Entity.update_balance_changeset(%{balance: balance})
      )
    end

    project %AmountDeposited{
      id: id,
      balance: balance
    } do
      multi
      |> Multi.update(
        :account,
        Entity
        |> Repo.get!(id)
        |> Entity.update_balance_changeset(%{balance: balance})
      )
    end
  end

  defmodule LogManager do
    @moduledoc nil

    use Commanded.ProcessManagers.ProcessManager,
      name: "BankAccounts.LogManager",
      router: FauxBanker.Router,
      consistency: :eventual

    import Ecto.Changeset
    alias Date
    alias Decimal
    alias UUID
    alias Ecto.{Changeset}

    alias FauxBanker.{Repo, LogRepo}

    alias FauxBanker.BankAccounts, as: Context
    alias Context.BankAccount
    alias Context.AccountLog, as: Entity

    alias Context.Accounts.Events.{
      AccountOpened,
      AmountWithdrawn,
      AmountDeposited
    }

    defstruct []

    def error({:error, %Changeset{}}, _event, _context),
      do: :skip

    def interested?(%AccountOpened{id: id}),
      do: {:start, id}

    def interested?(%AmountWithdrawn{id: id}),
      do: {:continue, id}

    def interested?(%AmountDeposited{id: id}),
      do: {:continue, id}

    def handle(_state, %AccountOpened{code: code, balance: balance}) do
      %Entity{}
      |> Entity.changeset(%{
        event: "Account Opened",
        code: code,
        description: "",
        amount: 0.0,
        current_balance: 0.0,
        next_balance: balance |> Decimal.to_float(),
        logged_at: DateTime.utc_now()
      })
      |> LogRepo.insert()

      nil
    end

    def handle(
          _state,
          %AmountWithdrawn{
            id: id,
            amount: amount,
            balance: balance,
            description: description
          } = event
        ) do
      event |> IO.inspect(label: "event.with")

      %BankAccount{balance: current_balance, code: code} =
        Repo.get!(BankAccount, id)

      %Entity{}
      |> Entity.changeset(%{
        event: "Amount Withdrawn",
        code: code,
        description: description,
        amount: amount |> Decimal.to_float(),
        current_balance: current_balance |> Decimal.to_float(),
        next_balance: balance |> Decimal.to_float(),
        logged_at: DateTime.utc_now()
      })
      |> LogRepo.insert()

      nil
    end

    def handle(_state, %AmountDeposited{
          id: id,
          description: description,
          amount: amount,
          balance: balance
        }) do
      %BankAccount{balance: current_balance, code: code} =
        Repo.get!(BankAccount, id)

      %Entity{}
      |> Entity.changeset(%{
        event: "Amount Deposited",
        code: code,
        description: description,
        amount: amount |> Decimal.to_float(),
        current_balance: current_balance |> Decimal.to_float(),
        next_balance: balance |> Decimal.to_float(),
        logged_at: DateTime.utc_now()
      })
      |> LogRepo.insert()

      nil
    end
  end
end
