defmodule FauxBanker.AccountRequests.Router do
  use Commanded.Commands.CompositeRouter

  alias FauxBanker.AccountRequests, as: Context

  router(Context.Requests.Router)
end
