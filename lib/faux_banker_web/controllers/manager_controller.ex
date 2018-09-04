defmodule FauxBankerWeb.ManagerController do
  @moduledoc false

  use FauxBankerWeb, :controller

  alias Ecto.Changeset

  alias FauxBanker.Guardian
  alias FauxBankerWeb.Router.Helpers, as: Routes

  alias FauxBanker.Clients, as: ClientContext
  alias FauxBanker.BankAccounts, as: BankAccountContext

  alias BankAccountContext.{BankAccount}

  def view_screen(conn, %{"code" => code}) do
    if client = ClientContext.get_client_by_code(code) do
      conn
      |> render("view.html",
        user: Guardian.Plug.current_resource(conn),
        client: client
      )
    else
      conn
      |> put_flash(:error, "Client not found")
      |> redirect(to: "/")
    end
  end

  def open_account_screen(conn, %{"code" => code}) do
    if client = ClientContext.get_client_by_code(code) do
      conn
      |> render("open_account.html",
        user: Guardian.Plug.current_resource(conn),
        client: client
      )
    else
      conn
      |> put_flash(:error, "Client not found")
      |> redirect(to: "/")
    end
  end

  def open_account(conn, %{"code" => code} = params) do
    if client = ClientContext.get_client_by_code(code) do
      case BankAccountContext.open_client_account(client, params) do
        {:ok, %BankAccount{code: account_code}} ->
          conn
          |> put_flash(
            :info,
            "Opened new account with account number, #{account_code}."
          )
          |> redirect(to: Routes.manager_path(conn, :view_screen, code))

        {:error, %Changeset{}} ->
          conn
          |> put_flash(:error, "Invalid data.")
          |> render("open_account.html",
            user: Guardian.Plug.current_resource(conn),
            client: client
          )
      end
    else
      conn
      |> put_flash(:error, "Client not found")
      |> redirect(to: "/")
    end
  end
end
