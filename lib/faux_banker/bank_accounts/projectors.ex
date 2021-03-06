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
      AmountDeposited,
      AmountTransferred,
      AmountReceived
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

    project %AmountTransferred{
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

    project %AmountReceived{
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

    alias Date
    alias Decimal
    alias UUID

    alias FauxBanker.{Repo, LogRepo}

    alias FauxBanker.AccountRequests.AccountRequest

    alias FauxBanker.BankAccounts, as: Context
    alias Context.BankAccount
    alias Context.AccountLog, as: Entity

    alias Context.Accounts.Events.{
      AccountOpened,
      AmountWithdrawn,
      AmountDeposited,
      AmountTransferred,
      AmountReceived
    }

    defstruct []

    def error({:error, _failure}, _command, %{context: %{failures: failures}})
        when failures >= 3,
        do: {:skip, :continue_pending}

    def error({:error, _failure}, _command, %{context: context}),
      do: {:retry, 10, Map.update(context, :failures, 1, &(&1 + 1))}

    def interested?(%AccountOpened{id: id}),
      do: {:start, id}

    def interested?(%AmountWithdrawn{id: id}),
      do: {:continue, id}

    def interested?(%AmountDeposited{id: id}),
      do: {:continue, id}

    def interested?(%AmountTransferred{id: id}),
      do: {:continue, id}

    def interested?(%AmountReceived{id: id}),
      do: {:continue, id}

    def handle(_state, %AccountOpened{code: code, balance: balance}) do
      %Entity{}
      |> Entity.changeset(%{
        event: "Account Opened",
        code: code,
        description: "",
        amount: 0.0,
        current_balance: 0.0,
        next_balance: Decimal.to_float(balance),
        logged_at: DateTime.utc_now()
      })
      |> LogRepo.insert()
      |> case do
        {:ok, _log} -> nil
        error -> error
      end
    end

    def handle(
          _state,
          %AmountWithdrawn{
            id: id,
            amount: amount,
            balance: balance,
            description: description
          }
        ) do
      %BankAccount{balance: current_balance, code: code} =
        Repo.get!(BankAccount, id)

      %Entity{}
      |> Entity.changeset(%{
        event: "Amount Withdrawn",
        code: code,
        description: description,
        amount: Decimal.to_float(amount),
        current_balance: Decimal.to_float(current_balance),
        next_balance: Decimal.to_float(balance),
        logged_at: DateTime.utc_now()
      })
      |> LogRepo.insert()
      |> case do
        {:ok, _log} -> nil
        error -> error
      end
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
        amount: Decimal.to_float(amount),
        current_balance: Decimal.to_float(current_balance),
        next_balance: Decimal.to_float(balance),
        logged_at: DateTime.utc_now()
      })
      |> LogRepo.insert()
      |> case do
        {:ok, _log} -> nil
        error -> error
      end
    end

    def handle(_state, %AmountTransferred{
          id: id,
          request_id: request_id,
          amount: amount,
          balance: balance,
          previous_balance: current_balance
        }) do
      if request = Repo.get(AccountRequest, request_id) do
        %BankAccount{code: code} = Repo.get!(BankAccount, id)

        %AccountRequest{receipient_reason: reason, code: request_code} = request

        %Entity{}
        |> Entity.changeset(%{
          event: "Amount Transferred",
          code: code,
          request_code: request_code,
          description: reason,
          amount: Decimal.to_float(amount),
          current_balance: Decimal.to_float(current_balance),
          next_balance: Decimal.to_float(balance),
          logged_at: DateTime.utc_now()
        })
        |> LogRepo.insert()
        |> case do
          {:ok, _log} -> nil
          error -> error
        end
      else
        {:error, :request_not_found}
      end
    end

    def handle(_state, %AmountReceived{
          id: id,
          request_id: request_id,
          amount: amount,
          balance: balance,
          previous_balance: current_balance
        }) do
      if request = Repo.get(AccountRequest, request_id) do
        %AccountRequest{sender_reason: reason, code: request_code} = request

        %BankAccount{code: code} = Repo.get!(BankAccount, id)

        %Entity{}
        |> Entity.changeset(%{
          event: "Amount Received",
          code: code,
          request_code: request_code,
          description: reason,
          amount: Decimal.to_float(amount),
          current_balance: Decimal.to_float(current_balance),
          next_balance: Decimal.to_float(balance),
          logged_at: DateTime.utc_now()
        })
        |> LogRepo.insert()
        |> case do
          {:ok, _log} -> nil
          error -> error
        end
      else
        {:error, :request_not_found}
      end
    end
  end
end
