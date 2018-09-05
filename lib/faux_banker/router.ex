defmodule FauxBanker.Router do
  use Commanded.Commands.CompositeRouter

  router(FauxBanker.AccountRequests.Router)
  router(FauxBanker.BankAccounts.Router)
end
