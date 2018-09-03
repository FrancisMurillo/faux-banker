defmodule FauxBankerWeb.ClientController do
  @moduledoc false

  use FauxBankerWeb, :controller

  alias FauxBanker.Guardian
  alias FauxBankerWeb.Router.Helpers, as: Routes

  alias FauxBanker.Clients, as: Context

  def view_screen(conn, %{"code" => code}) do
    if client = Context.get_client_by_code(code) do
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
end
