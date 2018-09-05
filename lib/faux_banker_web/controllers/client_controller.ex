defmodule FauxBankerWeb.ClientController do
  @moduledoc false

  use FauxBankerWeb, :controller

  alias Ecto.Changeset

  alias FauxBanker.Guardian
  alias FauxBankerWeb.Router.Helpers, as: Routes

  alias FauxBanker.{Accounts, AccountRequests, BankAccounts, Clients}

  alias Accounts.{User}
  alias AccountRequests.{AccountRequest}
  alias BankAccounts.{BankAccount}

  def view_screen(conn, %{"code" => code}) do
    if account = BankAccounts.get_account_by_code(code) do
      conn
      |> render("view.html",
        user: Guardian.Plug.current_resource(conn),
        account: account
      )
    else
      conn
      |> put_flash(:error, "Account not found")
      |> redirect(to: "/")
    end
  end

  def withdraw_screen(conn, %{"code" => code}) do
    if account = BankAccounts.get_account_by_code(code) do
      conn
      |> render("withdraw.html",
        user: Guardian.Plug.current_resource(conn),
        account: account
      )
    else
      conn
      |> put_flash(:error, "Account not found")
      |> redirect(to: "/")
    end
  end

  def withdraw(conn, %{"code" => code} = params) do
    if account = BankAccounts.get_account_by_code(code) do
      case BankAccounts.withdraw_from_account(account, params) do
        {:ok, %BankAccount{code: account_code}} ->
          conn
          |> put_flash(
            :info,
            "Withdrew successfuly from account number, #{account_code}."
          )
          |> redirect(to: Routes.client_path(conn, :view_screen, code))

        {:error, %Changeset{}} ->
          conn
          |> put_flash(:error, "Invalid data.")
          |> render("withdraw.html",
            user: Guardian.Plug.current_resource(conn),
            account: account
          )

        {:error, :invalid_amount} ->
          conn
          |> put_flash(
            :error,
            "Amount must not be greater than current balance."
          )
          |> render("withdraw.html",
            user: Guardian.Plug.current_resource(conn),
            account: account
          )
      end
    else
      conn
      |> put_flash(:error, "Account not found")
      |> redirect(to: "/")
    end
  end

  def deposit_screen(conn, %{"code" => code}) do
    if account = BankAccounts.get_account_by_code(code) do
      conn
      |> render("deposit.html",
        user: Guardian.Plug.current_resource(conn),
        account: account
      )
    else
      conn
      |> put_flash(:error, "Account not found")
      |> redirect(to: "/")
    end
  end

  def deposit(conn, %{"code" => code} = params) do
    if account = BankAccounts.get_account_by_code(code) do
      case BankAccounts.deposit_to_account(account, params) do
        {:ok, %BankAccount{code: account_code}} ->
          conn
          |> put_flash(
            :info,
            "Deposited successfully to account number, #{account_code}."
          )
          |> redirect(to: Routes.client_path(conn, :view_screen, code))

        {:error, %Changeset{}} ->
          conn
          |> put_flash(:error, "Invalid data.")
          |> render("deposit.html",
            user: Guardian.Plug.current_resource(conn),
            account: account
          )
      end
    else
      conn
      |> put_flash(:error, "Account not found")
      |> redirect(to: "/")
    end
  end

  def make_request_screen(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    %User{id: id} = user

    accounts = BankAccounts.list_accounts_by_client_id(id)
    friends = Clients.list_client_friends_by_id(id)

    conn
    |> render("make_request.html",
      user: user,
      accounts: accounts,
      friends: friends
    )
  end

  def make_request(conn, params) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, client} <- Clients.user_as_client(user),
         {:ok, %AccountRequest{}} <-
           AccountRequests.make_client_request(client, params) do
      conn
      |> put_flash(
        :info,
        "Created request"
      )
      |> redirect(to: "/")
    else
      {:error, %Changeset{}} ->
        %User{id: id} = user
        accounts = BankAccounts.list_accounts_by_client_id(id)
        friends = Clients.list_client_friends_by_id(id)

        conn
        |> put_flash(:error, "Invalid data.")
        |> render("make_request.html",
          user: Guardian.Plug.current_resource(conn),
          accounts: accounts,
          friends: friends
        )

      {:error, :invalid_user} ->
        conn
        |> put_flash(:error, "Invalid user.")
        |> redirect(to: "/")
    end
  end

  def approve_request_screen(conn, %{"code" => code}) do
    if request = AccountRequests.get_request_by_code(code) do
      %AccountRequest{sender_id: id} = request

      accounts = BankAccounts.list_accounts_by_client_id(id)

      conn
      |> render("approve_request.html",
        user: Guardian.Plug.current_resource(conn),
        request: request,
        accounts: accounts
      )
    else
      conn
      |> put_flash(:error, "Request not found")
      |> redirect(to: "/")
    end
  end

  def approve_request(conn, %{"code" => code} = params) do
    if request = AccountRequests.get_request_by_code(code) do
      case AccountRequests.approve_request(request, params) do
        {:ok, %AccountRequest{code: account_code}} ->
          conn
          |> put_flash(
            :info,
            "Deposited successfully to account number, #{account_code}."
          )
          |> redirect(to: Routes.client_path(conn, :view_screen, code))

        {:error, %Changeset{}} ->
          conn
          |> put_flash(:error, "Invalid data.")
          |> render("approve_request.html",
            user: Guardian.Plug.current_resource(conn),
            request: request
          )
      end
    else
      conn
      |> put_flash(:error, "Request not found")
      |> redirect(to: "/")
    end
  end
end
