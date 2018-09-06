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
  alias FauxBanker.BankAccounts.Accounts.Aggregates, as: BankAccountAggregates

  alias FauxBanker.AccountRequests, as: Context
  alias Context.Requests.Aggregates, as: RequestAggregates
  alias Context.Requests.Events.{RequestMade, RequestApproved, RequestRejected}
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

      %AccountRequest{
        receipient_account: receipient_account,
        sender_account: sender_account
      } = pending_request

      :ok =
        RequestAggregates
        |> struct(Map.from_struct(pending_request))
        |> Router.dispatch()

      :ok =
        BankAccountAggregates
        |> struct(Map.from_struct(receipient_account))
        |> Router.dispatch()

      :ok =
        BankAccountAggregates
        |> struct(Map.from_struct(sender_account))
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

      assert {:error, :invalid_status} =
               Context.approve_request(pending_request, params)
    end

    @tag :negative
    test "should fail safely", %{request: pending_request} do
      assert {:error, %Changeset{}} =
               Context.approve_request(pending_request, %{})
    end

    @tag :integration
    test "should transfer amounts", %{request: pending_request} do
      %AccountRequest{
        receipient_account: receipient_account,
        sender_account: sender_account
      } = pending_request

      %BankAccount{code: code} = receipient_account

      params = string_params_for(:approve_request, %{account_code: code})

      assert {:ok, request} = Context.approve_request(pending_request, params)

      assert %AccountRequest{status: :approved} = request

      Process.sleep(50)

      %AccountRequest{
        receipient_account: updated_receipient_account,
        sender_account: updated_sender_account
      } =
        request
        |> Repo.preload([:receipient_account, :sender_account],
          force: true
        )

      assert Decimal.cmp(updated_sender_account.balance, sender_account.balance) ==
               :gt

      assert Decimal.cmp(
               updated_receipient_account.balance,
               receipient_account.balance
             ) == :lt
    end
  end

  describe "Context.reject_request/2" do
    setup do
      pending_request =
        insert(:request, %{status: :pending, amount: Decimal.new(1)})

      %AccountRequest{
        receipient_account: receipient_account,
        sender_account: sender_account
      } = pending_request

      :ok =
        RequestAggregates
        |> struct(Map.from_struct(pending_request))
        |> Router.dispatch()

      :ok =
        BankAccountAggregates
        |> struct(Map.from_struct(receipient_account))
        |> Router.dispatch()

      :ok =
        BankAccountAggregates
        |> struct(Map.from_struct(sender_account))
        |> Router.dispatch()

      %{request: pending_request}
    end

    @tag :positive
    test "should work and only once", %{request: pending_request} do
      params = string_params_for(:reject_request, %{})

      assert {:ok, %AccountRequest{status: :rejected}} =
               Context.reject_request(pending_request, params)

      assert {:error, :invalid_status} =
               Context.reject_request(pending_request, params)
    end

    @tag :negative
    test "should fail safely", %{request: pending_request} do
      assert {:error, %Changeset{}} =
               Context.reject_request(pending_request, %{})
    end

    @tag :integration
    test "should not change balance", %{request: pending_request} do
      %AccountRequest{sender_account: sender_account} = pending_request

      params = string_params_for(:reject_request, %{})

      assert {:ok, request} = Context.reject_request(pending_request, params)

      assert %AccountRequest{
               status: :rejected,
               sender_account: updated_sender_account
             } =
               request
               |> Repo.preload([:sender_account],
                 force: true
               )

      assert Decimal.cmp(updated_sender_account.balance, sender_account.balance) ==
               :eq
    end
  end

  describe "Context.MailSaga" do
    use Bamboo.Test

    setup do
      request = insert(:request, %{})

      %{request: request}
    end

    @tag :positive
    test "notification email for making requests should work", %{
      request: request
    } do
      event = struct(RequestMade, Map.from_struct(request))
      %RequestMade{id: id} = event

      assert {:start, ^id} = MailSaga.interested?(event)
      assert MailSaga.handle(nil, event) == nil
      assert_delivered_email(MailSaga.request_money_email(request))
    end

    @tag :positive
    test "notification email for approving requests should work", %{
      request: request
    } do
      event = struct(RequestApproved, Map.from_struct(request))
      %RequestApproved{id: id} = event

      assert {:continue, ^id} = MailSaga.interested?(event)
      assert MailSaga.handle(nil, event) == nil
      assert_delivered_email(MailSaga.request_approved_email(request))
    end

    @tag :positive
    test "notification email for rejecting requests should work", %{
      request: request
    } do
      event = struct(RequestRejected, Map.from_struct(request))
      %RequestRejected{id: id} = event

      assert {:continue, ^id} = MailSaga.interested?(event)
      assert MailSaga.handle(nil, event) == nil
      assert_delivered_email(MailSaga.request_rejected_email(request))
    end
  end
end
