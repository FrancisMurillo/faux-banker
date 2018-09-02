defmodule FauxBankerWeb.HomeController do
  @moduledoc false

  use FauxBankerWeb, :controller

  def home_screen(conn, _params) do
    conn
    |> render("home.html")
  end
end
