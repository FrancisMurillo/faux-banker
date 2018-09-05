defmodule FauxBanker.AccountRequests.ProcessManagers do
  defmodule MailSaga do
    @moduledoc nil

    use Commanded.ProcessManagers.ProcessManager,
      name: "AccountRequests.MailProcessManager",
      router: FauxBanker.Router,
      consistency: :eventual

    import Bamboo.Email

    alias FauxBanker.{Mailer, Repo}

    alias FauxBanker.BankAccounts.BankAccount

    alias FauxBanker.AccountRequests, as: Context
    alias Context.AccountRequest

    alias Context.Requests.Events.{
      RequestMade
    }

    defstruct []

    def interested?(%RequestMade{id: id}),
      do: {:start, id}

    def error({:error, _failure}, _command, %{context: %{failures: failures}})
        when failures >= 3,
        do: {:skip, :continue_pending}

    def error({:error, _failure}, _command, %{context: context}),
      do: {:retry, 100, Map.update(context, :failures, 1, &(&1 + 1))}

    def request_money_email(%AccountRequest{} = request) do
      %AccountRequest{
        sender_reason: reason,
        amount: amount,
        receipient: %{email: email, first_name: receipient_first_name},
        sender: %{first_name: sender_first_name},
        sender_account: %BankAccount{name: account}
      } =
        request
        |> Repo.preload([:sender, :receipient, :sender_account])

      base_email()
      |> to(email)
      |> subject("Request Money")
      |> text_body("""
      Hello #{sender_first_name},

      Your friend, #{receipient_first_name}, needs #{Decimal.round(amount)} for his account, #{
        account
      }. and says...

      #{reason}

      Go back to the site and check it out.
      """)
    end

    def handle(_state, %RequestMade{id: id}) do
      if request = Repo.get(AccountRequest, id) do
        request
        |> request_money_email()
        |> Mailer.deliver_later()

        nil
      else
        {:error, :request_not_found}
      end
    end

    defp base_email,
      do:
        new_email()
        |> from("faux_banker@invento.io")
  end
end
