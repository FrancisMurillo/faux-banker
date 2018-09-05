defmodule FauxBanker.AccountRequestsFactory do
  @moduledoc false
  defmacro __using__(_opts) do
    quote do
      alias FauxBanker.Generator

      alias FauxBanker.AccountRequests, as: Context
      alias Context.AccountRequest

      def make_request_factory,
        do: %{
          amount: Generator.decimal(),
          reason: Generator.description(),
          friend_code: Generator.code(),
          account_code: Generator.code()
        }

      def approve_request_factory,
        do: %{
          account_code: Generator.code(),
          reason: Generator.description()
        }

      def reject_request_factory,
        do: %{
          reason: Generator.description()
        }

      def request_factory,
        do: %AccountRequest{
          id: Generator.id(),
          code: Generator.code(),
          amount: Generator.decimal(),
          status: Generator.request_status(),
          sender_reason: Generator.description(),
          receipient_reason: Generator.description(),
          sender: build(:client_user, %{accounts: []}),
          sender_account: build(:bank_account, %{}),
          receipient: build(:client_user, %{accounts: []}),
          receipient_account: build(:bank_account, %{})
        }
    end
  end
end
