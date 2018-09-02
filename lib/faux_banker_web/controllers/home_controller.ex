defmodule FauxBankerWeb.HomeController do
  @moduledoc false

  use FauxBankerWeb, :controller

  def home_screen(conn, _params),
    do: render(conn, "home.html")
end
