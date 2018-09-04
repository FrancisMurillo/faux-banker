defmodule FauxBankerWeb.ManagerView do
  use FauxBankerWeb, :view

  alias FauxBanker.{BankAccounts}

  def bank_accounts(client_id),
    do: BankAccounts.list_accounts_by_client_id(client_id)
end
