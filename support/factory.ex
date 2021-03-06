defmodule FauxBanker.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: FauxBanker.Repo

  use FauxBanker.AccountsFactory
  use FauxBanker.AccountRequestsFactory
  use FauxBanker.BankAccountsFactory
end
