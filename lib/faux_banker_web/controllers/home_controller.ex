defmodule FauxBankerWeb.HomeController do
  @moduledoc false

  use FauxBankerWeb, :controller

  alias FauxBanker.Guardian

  def home_screen(conn, _params) do
    render(conn, "home.html", user: Guardian.Plug.current_resource(conn))
  end
end
