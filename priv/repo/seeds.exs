alias Comeonin.Bcrypt, as: Comeonin

import FauxBanker.Factory

{:ok, _} = Application.ensure_all_started(:faux_banker)

:user
|> insert(%{
  username: "manager",
  email: "manager@email.com",
  role: :manager,
  password_hash: Comeonin.hashpwsalt("123456")
})
