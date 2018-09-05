defmodule FauxBanker.BankAccounts.ProcessManagers do
  defmodule TransferRequestSaga do
    @moduledoc nil

    use Commanded.ProcessManagers.ProcessManager,
      name: "BankAccounts.TransferProcessManager",
      router: FauxBanker.Router,
      consistency: :strong

    alias FauxBanker.{Repo}

    alias FauxBanker.AccountRequests.AccountRequest
    alias FauxBanker.AccountRequests.Requests.Events.RequestApproved

    alias FauxBanker.BankAccounts, as: Context
    alias Context.BankAccount

    defstruct []

    def interested?(%RequestApproved{id: id}),
      do: {:start, id}

    def error({:error, _failure}, _command, %{context: %{failures: failures}})
        when failures >= 3,
        do: {:skip, :continue_pending}

    def error({:error, _failure}, _command, %{context: context}),
      do: {:retry, 100, Map.update(context, :failures, 1, &(&1 + 1))}

    def handle(_state, %RequestApproved{id: id}) do
      request = Repo.get!(AccountRequest, id)

      nil
    end
  end
end
