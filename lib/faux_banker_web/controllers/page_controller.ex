defmodule FauxBankerWeb.PageController do
  use FauxBankerWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
