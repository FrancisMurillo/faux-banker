defmodule FauxBanker.AccountsFactory do
  @moduledoc false
  defmacro __using__(_opts) do
    quote do
      alias FauxBanker.Generator

      alias FauxBanker.Accounts, as: Context
      alias Context.User

      def user_factory,
        do: %User{
          id: Generator.id(),
          username: Generator.username(),
          password: Generator.password(),
          password_hash: Generator.hashed_password(),
          email: Generator.email(),
          role: Generator.role(),
          first_name: Generator.name(),
          last_name: Generator.name(),
          phone_number: Generator.phone_number()
        }
    end
  end
end
