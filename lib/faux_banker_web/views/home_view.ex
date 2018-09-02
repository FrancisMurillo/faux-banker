defmodule FauxBankerWeb.HomeView do
  use FauxBankerWeb, :view

  alias FauxBanker.{Clients}

  def clients(),
    do: Clients.list_clients()
end
