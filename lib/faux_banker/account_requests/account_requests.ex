defmodule FauxBanker.AccountRequests do
  @moduledoc nil

  alias FauxBanker.Repo

  alias FauxBanker.BankAccounts.BankAccount
  alias FauxBanker.Clients.Client

  alias __MODULE__, as: Context

  alias Context.AccountRequest

  defmodule Queries do
    @moduledoc nil

    import Ecto.Query

    def select_client_requests(client_id),
      do:
        from(a in AccountRequest,
          inner_join: s in Client,
          on: s.id == a.sender_id,
          inner_join: sb in BankAccount,
          on: sb.id == a.sender_account_id,
          inner_join: r in Client,
          on: r.id == a.receipient_id,
          inner_join: rb in BankAccount,
          on: rb.id == a.receipient_account_id,
          where: a.sender_id == ^client_id or a.receipient_id == ^client_id,
          preload: [
            sender: s,
            sender_account: sb,
            receipient: r,
            receipient_account: rb
          ]
        )
  end

  def list_client_requests_by_client_id(client_id),
    do: client_id |> Context.Queries.select_client_requests() |> Repo.all()

  def make_client_request(%Client{} = client, params) do
  end
end
