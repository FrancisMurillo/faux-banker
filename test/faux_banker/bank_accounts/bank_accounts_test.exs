defmodule FauxBanker.BankAccountsTest do
  use FauxBanker.DataCase

  alias Decimal
  alias Ecto.Changeset

  import FauxBanker.Factory
  alias FauxBanker.{LogRepo, Router}

  alias FauxBanker.Accounts.User
  alias FauxBanker.AccountRequests.AccountRequest
  alias FauxBanker.Clients

  alias FauxBanker.BankAccounts, as: Context
  alias Context.{BankAccount, AccountLog}
  alias Context.Accounts.Aggregates, as: AccountAggregates
  alias Context.Accounts.Commands.{TransferAmount, ReceiveAmount}

  describe "Context.open_client_account/2" do
    setup do
      %User{code: code} = insert(:client_user, %{accounts: []})

      %{client: Clients.get_client_by_code(code)}
    end

    @tag :positive
    test "should work and only once", %{client: client} do
      params = string_params_for(:open_client_account, %{})

      assert {:ok, %BankAccount{}} = Context.open_client_account(client, params)

      assert {:error, %Changeset{}} =
               Context.open_client_account(client, params)
    end

    @tag :negative
    test "should fail safely", %{client: client} do
      assert {:error, %Changeset{}} = Context.open_client_account(client, %{})
    end
  end

  describe "Context.withdraw_from_account/2" do
    setup do
      account = insert(:bank_account, %{})

      :ok =
        Router.dispatch(AccountAggregates |> struct(Map.from_struct(account)))

      %{account: account}
    end

    @tag :positive
    test "should work", %{account: account} do
      %BankAccount{balance: raw_balance} = account
      balance = Decimal.to_integer(raw_balance)

      assert {:ok, %BankAccount{}} =
               Context.withdraw_from_account(account, %{
                 amount: :rand.uniform(balance - 1)
               })
    end

    @tag :negative
    test "should fail safely", %{account: account} do
      assert {:error, %Changeset{}} =
               Context.withdraw_from_account(account, %{})

      %BankAccount{balance: raw_balance} = account
      balance = Decimal.to_integer(raw_balance)

      assert {:error, :invalid_amount} =
               Context.withdraw_from_account(account, %{
                 amount: balance + 1
               })
    end

    @tag :concurrency
    test "should fail with concurrent requests", %{account: account} do
      %BankAccount{balance: raw_balance} = account
      balance = Decimal.to_integer(raw_balance)

      %{error: :constraint_error, ok: %BankAccount{}} =
        1
        |> Range.new(3)
        |> Enum.map(fn _ ->
          Task.async(fn ->
            Context.withdraw_from_account(
              account,
              %{amount: balance}
            )
          end)
        end)
        |> Enum.map(&Task.await/1)
        |> Map.new()
    end
  end

  describe "Context.deposit_to_account/2" do
    setup do
      account = insert(:bank_account, %{})

      :ok =
        Router.dispatch(AccountAggregates |> struct(Map.from_struct(account)))

      %{account: account}
    end

    @tag :positive
    test "should work", %{account: account} do
      %BankAccount{balance: raw_balance} = account
      balance = Decimal.to_integer(raw_balance)

      assert {:ok, %BankAccount{}} =
               Context.deposit_to_account(account, %{
                 amount: :rand.uniform(balance)
               })
    end

    @tag :negative
    test "should fail safely", %{account: account} do
      assert {:error, %Changeset{}} = Context.deposit_to_account(account, %{})
    end
  end

  describe "Context.AccountLogs" do
    @tag :positive
    test "should log newly opened account" do
      %User{code: code} = insert(:client_user, %{accounts: []})

      client = Clients.get_client_by_code(code)
      params = string_params_for(:open_client_account, %{})

      assert {:ok, %BankAccount{code: account_code}} =
               Context.open_client_account(client, params)

      Process.sleep(0)

      assert %AccountLog{} =
               LogRepo.get_by(AccountLog,
                 code: account_code,
                 event: "Account Opened"
               )
    end

    @tag :positive
    test "should log withdrawn amount" do
      account = insert(:bank_account, %{})
      %BankAccount{code: code} = account

      :ok =
        Router.dispatch(AccountAggregates |> struct(Map.from_struct(account)))

      assert {:ok, %BankAccount{}} =
               Context.withdraw_from_account(account, %{
                 amount: :rand.uniform(10)
               })

      Process.sleep(0)

      assert %AccountLog{} =
               LogRepo.get_by(AccountLog, code: code, event: "Amount Withdrawn")
    end

    @tag :positive
    test "should log deposited amount" do
      account = insert(:bank_account, %{})
      %BankAccount{code: code} = account

      :ok =
        Router.dispatch(AccountAggregates |> struct(Map.from_struct(account)))

      assert {:ok, %BankAccount{}} =
               Context.deposit_to_account(account, %{
                 amount: :rand.uniform(10)
               })

      Process.sleep(0)

      assert %AccountLog{} =
               LogRepo.get_by(AccountLog, code: code, event: "Amount Deposited")
    end

    @tag :positive
    test "should log transferred amount" do
      request = insert(:request, %{})

      %AccountRequest{
        id: request_id,
        code: request_code,
        receipient_account_id: receipient_account_id,
        receipient_account: receipient_account
      } = request

      :ok =
        AccountAggregates
        |> struct(Map.from_struct(receipient_account))
        |> Router.dispatch()

      assert :ok =
               %TransferAmount{
                 id: receipient_account_id,
                 request_id: request_id,
                 amount: Decimal.new(1)
               }
               |> Router.dispatch()

      Process.sleep(50)

      assert %AccountLog{} =
               LogRepo.get_by(AccountLog,
                 request_code: request_code,
                 event: "Amount Transferred"
               )
    end

    @tag :positive
    test "should log received amount" do
      request = insert(:request, %{})

      %AccountRequest{
        id: request_id,
        code: request_code,
        sender_account_id: sender_account_id,
        sender_account: sender_account
      } = request

      :ok =
        AccountAggregates
        |> struct(Map.from_struct(sender_account))
        |> Router.dispatch()

      assert :ok =
               %ReceiveAmount{
                 id: sender_account_id,
                 request_id: request_id,
                 amount: Decimal.new(1)
               }
               |> Router.dispatch()

      Process.sleep(50)

      assert %AccountLog{} =
               LogRepo.get_by(AccountLog,
                 request_code: request_code,
                 event: "Amount Received"
               )
    end
  end
end
