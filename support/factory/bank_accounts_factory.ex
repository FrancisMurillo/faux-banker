defmodule FauxBanker.BankAccountsFactory do
  @moduledoc false
  defmacro __using__(_opts) do
    quote do
      alias FauxBanker.Generator

      alias FauxBanker.BankAccounts, as: Context
      alias Context.BankAccount

      def bank_account_factory,
        do: %BankAccount{
          id: Generator.id(),
          code: Generator.code(),
          name: Generator.account_name(),
          description: Generator.description(),
          balance: Generator.decimal()
        }

      def open_client_account_factory,
        do: %{
          name: Generator.account_name(),
          description: Generator.description(),
          initial_balance: Generator.decimal()
        }
    end
  end
end
