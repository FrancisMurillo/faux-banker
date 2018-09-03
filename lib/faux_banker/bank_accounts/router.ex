defmodule FauxBanker.BankAccounts.Router do
  use Commanded.Commands.CompositeRouter

  alias FauxBanker.BankAccounts, as: Context

  router(Context.Accounts.Router)
end
