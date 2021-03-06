defmodule FauxBanker.AccountRequests.Projectors do
  @moduledoc nil

  defmodule RequestManager do
    @moduledoc nil

    use Commanded.Projections.Ecto,
      name: "AccountRequests.RequestManager",
      consistency: :strong

    alias Ecto.{Changeset, Multi}

    alias FauxBanker.Repo

    alias FauxBanker.BankAccounts.BankAccount
    alias FauxBanker.Clients.Client

    alias FauxBanker.AccountRequests, as: Context
    alias Context.AccountRequest, as: Entity

    alias Context.Requests.Events.{
      RequestMade,
      RequestApproved,
      RequestRejected
    }

    def error({:error, %Changeset{}}, _event, _context),
      do: :skip

    project %RequestMade{
      id: id,
      sender_id: sender_id,
      sender_account_id: sender_account_id,
      receipient_id: receipient_id,
      code: code,
      amount: amount,
      sender_reason: sender_reason
    } do
      sender = Repo.get!(Client, sender_id)
      sender_account = Repo.get!(BankAccount, sender_account_id)

      receipient = Repo.get!(Client, receipient_id)

      multi
      |> Multi.insert(
        :request,
        %Entity{id: id}
        |> Entity.make_request_changeset(
          sender,
          sender_account,
          receipient,
          %{code: code, sender_reason: sender_reason, amount: amount}
        )
      )
    end

    project %RequestApproved{
      id: id,
      receipient_reason: receipient_reason,
      receipient_account_id: receipient_account_id
    } do
      receipient_account = Repo.get!(BankAccount, receipient_account_id)

      multi
      |> Multi.update(
        :request,
        Entity
        |> Repo.get!(id)
        |> Entity.approve_request_changeset(
          receipient_account,
          %{receipient_reason: receipient_reason}
        )
      )
    end

    project %RequestRejected{id: id, receipient_reason: receipient_reason} do
      multi
      |> Multi.update(
        :request,
        Entity
        |> Repo.get!(id)
        |> Entity.reject_request_changeset(%{
          receipient_reason: receipient_reason
        })
      )
    end
  end
end
