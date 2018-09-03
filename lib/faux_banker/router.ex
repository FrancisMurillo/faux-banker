defmodule FauxBanker.Router do
  use Commanded.Commands.CompositeRouter

  router(FauxBanker.BankAccounts.Router)
end
