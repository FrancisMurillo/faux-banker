defmodule FauxBankerWeb.HomeView do
  use FauxBankerWeb, :view

  alias FauxBanker.{BankAccounts, Clients, AccountRequests}

  def clients(),
    do: Clients.list_clients()

  def bank_accounts(client_id),
    do: BankAccounts.list_accounts_by_client_id(client_id)

  def friends(client_id),
    do: Clients.list_client_friends_by_id(client_id)

  def requests(client_id),
    do: AccountRequests.list_client_requests_by_client_id(client_id)
end
