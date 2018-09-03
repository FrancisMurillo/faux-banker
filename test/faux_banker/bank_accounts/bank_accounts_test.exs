defmodule FauxBanker.BankAccountsTest do
  use FauxBanker.DataCase

  alias Ecto.Changeset

  import FauxBanker.Factory

  alias FauxBanker.Accounts.User

  alias FauxBanker.Clients, as: ClientContext

  alias FauxBanker.BankAccounts, as: Context
  alias Context.BankAccount

  describe "Context.open_client_account/2" do
    setup do
      %User{code: code} = insert(:client_user, %{accounts: []})

      %{client: ClientContext.get_client_by_code(code)}
    end

    @tag :positive
    test "should work and only once", %{client: client} do
      params = string_params_for(:bank_account, %{})

      assert {:ok, %BankAccount{}} = Context.open_client_account(client, params)

      assert {:error, %Changeset{}} =
               Context.open_client_account(client, params)
    end

    @tag :negative
    test "should fail safely", %{client: client} do
      assert {:error, %Changeset{}} = Context.open_client_account(client, %{})
    end
  end
end
