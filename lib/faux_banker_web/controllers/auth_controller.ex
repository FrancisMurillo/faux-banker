defmodule FauxBankerWeb.AuthController do
  @moduledoc false

  use FauxBankerWeb, :controller
  plug(Ueberauth)

  alias Ecto.Changeset
  alias Ueberauth.Auth
  alias Ueberauth.Strategy.Helpers

  alias FauxBanker.Guardian
  alias FauxBankerWeb.Router.Helpers, as: Routes

  alias FauxBanker.Accounts, as: Context
  alias FauxBanker.Accounts.User

  def register_client_form(conn, _params) do
    render(conn, "register_client.html")
  end

  def register_client(conn, params) do
    case Context.register_client(params) do
      {:ok, %User{} = user} ->
        conn
        |> Guardian.Plug.sign_in(user)
        |> put_flash(:info, "Successfully registered.")
        |> redirect(to: "/")

      {:error, %Changeset{}} ->
        conn
        |> put_flash(:error, "Invalid data.")
        |> render("register_client.html")
    end
  end

  def signin_form(conn, _params) do
    render(conn, "signin.html")
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params),
    do:
      conn
      |> put_flash(:error, "Failed to authenticate.")
      |> redirect(to: Routes.auth_path(:signin))

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, params) do
    case handle_auth(auth, params) do
      {:ok, user} ->
        conn
        |> Guardian.Plug.sign_in(user)
        |> put_flash(:info, "Successfully authenticated.")
        |> redirect(to: "/")

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Invalid username/email and/or password")
        |> redirect(to: Routes.auth_path(conn, :signin_form))
    end
  end

  defp handle_auth(%Auth{provider: :identity}, params),
    do: Context.find_user_by_authentication(params)

  defp handle_auth(%Auth{credentials: credentials}, _params),
    do: {:error, :not_implemented}

  def signout(conn, _params),
    do:
      conn
      |> Guardian.Plug.sign_out()
      |> put_flash(:info, "Logged out")
      |> redirect(to: Routes.auth_path(conn, :signin_form))
end
