defmodule FauxBankerWeb.ClientView do
  use FauxBankerWeb, :view

  alias FauxBanker.{BankAccounts}

  def account_logs(account_number),
    do: BankAccounts.list_account_logs_by_account_number(account_number)
end
