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
  alias Context.Requests.Events.{RequestMade}
  alias Context.ProcessManagers.{MailSaga}

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
      %Client{id: sender_id, accounts: [%BankAccount{code: account_code} | _]} =
        sender |> Repo.preload(:accounts)

      %Client{id: receipient_id, code: friend_code} = receipient

      params =
        string_params_for(:make_request, %{
          account_code: account_code,
          friend_code: friend_code
        })

      assert {:ok,
              %AccountRequest{
                status: :pending,
                receipient_id: ^receipient_id,
                sender_id: ^sender_id
              }} = Context.make_client_request(sender, params)

      assert {:ok, %AccountRequest{}} =
               Context.make_client_request(sender, params)
    end

    @tag :negative
    test "should fail safely", %{sender: sender} do
      assert {:error, %Changeset{}} = Context.make_client_request(sender, %{})
    end
  end

  describe "Context.approve_request/2" do
    setup do
      pending_request =
        insert(:request, %{status: :pending, amount: Decimal.new(1)})

      :ok =
        RequestAggregates
        |> struct(Map.from_struct(pending_request))
        |> Router.dispatch()

      %{request: pending_request}
    end

    @tag :positive
    test "should work and only once", %{request: pending_request} do
      %AccountRequest{receipient_account: %BankAccount{code: code}} =
        pending_request

      params = string_params_for(:approve_request, %{account_code: code})

      assert {:ok, %AccountRequest{status: :approved}} =
               Context.approve_request(pending_request, params)
    end
  end

  describe "Context.MailSaga" do
    use Bamboo.Test

    @tag :positive
    test "notification email should work" do
      request = insert(:request, %{})
      event = struct(RequestMade, Map.from_struct(request))
      %RequestMade{id: id} = event

      assert {:start, ^id} = MailSaga.interested?(event)
      assert MailSaga.handle(nil, event) == nil
      assert_delivered_email(MailSaga.request_money_email(request))
    end
  end
end
