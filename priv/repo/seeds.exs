alias Comeonin.Bcrypt, as: Comeonin

import FauxBanker.Factory

alias FauxBanker.{Repo, Router}
alias FauxBanker.BankAccounts.BankAccount
alias FauxBanker.BankAccounts.Accounts.Aggregates, as: AccountAggregates

{:ok, _} = Application.ensure_all_started(:faux_banker)

:user
|> insert(%{
  username: "manager",
  email: "manager@email.com",
  role: :manager,
  password_hash: Comeonin.hashpwsalt("123456"),
  accounts: []
})

:user
|> insert(%{
  username: "nobody",
  email: "nobody@email.com",
  role: :client,
  password_hash: Comeonin.hashpwsalt("123456")
})

BankAccount
|> Repo.all()
|> Enum.each(fn account ->
  :ok = Router.dispatch(AccountAggregates |> struct(Map.from_struct(account)))
end)
