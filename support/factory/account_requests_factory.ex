defmodule FauxBanker.AccountRequestsFactory do
  @moduledoc false
  defmacro __using__(_opts) do
    quote do
      alias FauxBanker.Generator

      alias FauxBanker.AccountRequests, as: Context
      alias Context.AccountRequest

      def make_request_factory,
        do: %{
          code: Generator.code(),
          amount: Generator.decimal(),
          reason: Generator.description()
        }
    end
  end
end
