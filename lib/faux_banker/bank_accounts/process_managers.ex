defmodule FauxBanker.BankAccounts.ProcessManagers do
  defmodule TransferRequestSaga do
    @moduledoc nil

    use Commanded.ProcessManagers.ProcessManager,
      name: "BankAccounts.TransferProcessManager",
      router: FauxBanker.Router,
      consistency: :eventual

    alias FauxBanker.{Repo}

    alias FauxBanker.AccountRequests.AccountRequest
    alias FauxBanker.AccountRequests.Requests.Events.RequestApproved

    alias FauxBanker.BankAccounts, as: Context
    alias Context.Accounts.Commands.{TransferAmount, ReceiveAmount}

    defstruct []

    def interested?(%RequestApproved{id: id}),
      do: {:start, id}

    def error({:error, _failure}, _command, %{context: %{failures: failures}})
        when failures >= 3,
        do: {:skip, :continue_pending}

    def error({:error, _failure}, _command, %{context: context}),
      do: {:retry, 10, Map.update(context, :failures, 1, &(&1 + 1))}

    def handle(_state, %RequestApproved{id: id}) do
      if request = Repo.get(AccountRequest, id) do
        %AccountRequest{
          amount: amount,
          sender_account_id: receiver_id,
          receipient_account_id: giver_id
        } = request

        if is_nil(giver_id) do
          {:error, :request_not_found}
        else
          [
            %TransferAmount{id: giver_id, request_id: id, amount: amount},
            %ReceiveAmount{id: receiver_id, request_id: id, amount: amount}
          ]
        end
      else
        {:error, :request_not_found}
      end
    end
  end
end
