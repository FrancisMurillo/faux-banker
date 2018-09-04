defmodule FauxBankerWeb.HomeView do
  use FauxBankerWeb, :view

  alias FauxBanker.{BankAccounts, Clients}

  def clients(),
    do: Clients.list_clients()

  def bank_accounts(client_id),
    do: BankAccounts.list_accounts_by_client_id(client_id)
end
