alias Comeonin.Bcrypt, as: Comeonin

import FauxBanker.Factory

alias Mongo

alias FauxBanker.{LogRepo, Repo, Router}
alias FauxBanker.BankAccounts.BankAccount
alias FauxBanker.BankAccounts.Accounts.Aggregates, as: AccountAggregates

{:ok, _} = Application.ensure_all_started(:faux_banker)

Mongo.Ecto.truncate(LogRepo)

:user
|> insert(%{
  username: "manager",
  email: "manager@email.com",
  first_name: "Manager",
  role: :manager,
  password_hash: Comeonin.hashpwsalt("123456"),
  accounts: []
})

:user
|> insert(%{
  username: "nobody",
  email: "nobody@email.com",
  first_name: "Nobody",
  role: :client,
  password_hash: Comeonin.hashpwsalt("123456")
})

:user
|> insert(%{
  username: "another",
  email: "another@email.com",
  first_name: "Another",
  role: :client,
  password_hash: Comeonin.hashpwsalt("123456")
})

:user
|> insert(%{
  username: "somebody",
  email: "somebody@email.com",
  first_name: "Somebody",
  role: :client,
  password_hash: Comeonin.hashpwsalt("123456")
})

BankAccount
|> Repo.all()
|> Enum.each(fn account ->
  :ok = Router.dispatch(AccountAggregates |> struct(Map.from_struct(account)))
end)
