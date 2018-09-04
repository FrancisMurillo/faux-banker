defmodule FauxBanker.BankAccountsTest do
  use FauxBanker.DataCase

  alias Decimal
  alias Ecto.Changeset

  import FauxBanker.Factory
  alias FauxBanker.Router

  alias FauxBanker.Accounts.User

  alias FauxBanker.Clients, as: ClientContext

  alias FauxBanker.BankAccounts, as: Context
  alias Context.BankAccount
  alias Context.Accounts.Aggregates, as: AccountAggregates

  describe "Context.open_client_account/2" do
    setup do
      %User{code: code} = insert(:client_user, %{accounts: []})

      %{client: ClientContext.get_client_by_code(code)}
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
end
