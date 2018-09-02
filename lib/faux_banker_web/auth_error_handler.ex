defmodule FauxBankerWeb.AuthErrorHandler do
  @moduledoc nil

  use FauxBankerWeb, :controller

  import Phoenix.Controller
  import Plug.Conn

  alias FauxBankerWeb.Router.Helpers, as: Routes

  def auth_error(conn, {type, reason}, _opts) do
    message =
      cond do
        type == :unauthenticated ->
          "We don't know who you are. Sign in so we can tell."

        true ->
          reason
      end

    conn
    |> put_flash(:error, message)
    |> redirect(to: Routes.auth_path(conn, :signin_form))
  end
end
