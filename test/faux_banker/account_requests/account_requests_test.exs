defmodule FauxBanker.AccountRequestsTest do
  use FauxBanker.DataCase

  alias Decimal
  alias Ecto.Changeset

  import FauxBanker.Factory
  alias FauxBanker.{Repo, Router}

  alias FauxBanker.Clients
  alias FauxBanker.Clients.Client

  alias FauxBanker.Accounts.User
  alias FauxBanker.AccountRequests.AccountRequest
  alias FauxBanker.BankAccounts.BankAccount

  alias FauxBanker.AccountRequests, as: Context
  alias Context.Requests.Aggregates, as: RequestAggregates

  describe "Context.make_client_request/2" do
    setup do
      %User{code: sender_code} = insert(:client_user, %{})
      %User{code: receipient_code} = insert(:client_user, %{})

      %{
        sender: Clients.get_client_by_code(sender_code),
        receipient: Clients.get_client_by_code(receipient_code)
      }
    end

    @tag :positive
    test "should work and repeatedly", %{sender: sender, receipient: receipient} do
      %Client{accounts: [%BankAccount{code: account_code} | _]} =
        sender |> Repo.preload(:accounts)

      %Client{code: friend_code} = receipient

      params =
        :make_request
        |> string_params_for(%{
          account_code: account_code,
          friend_code: friend_code
        })
        |> Map.drop(["code", "id"])

      assert {:ok, %AccountRequest{status: :pending}} =
               Context.make_client_request(sender, params)

      assert {:ok, %AccountRequest{}} =
               Context.make_client_request(sender, params)
    end

    @tag :negative
    test "should fail safely", %{sender: sender} do
      assert {:error, %Changeset{}} = Context.make_client_request(sender, %{})
    end
  end
end
