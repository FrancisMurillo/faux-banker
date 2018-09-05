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
    alias FauxBanker.Clients.Client

    alias FauxBanker.AccountRequests, as: Context
    alias Context.AccountRequest

    alias Context.Requests.Events.{
      RequestMade
    }

    defstruct []

    def interested?(%RequestMade{id: id}),
      do: {:start, id}

    def handle(_state, %RequestMade{id: id}) do
      request =
        AccountRequest
        |> Repo.get!(id)
        |> Repo.preload([:sender, :receipient, :sender_account])

      %AccountRequest{
        sender_reason: reason,
        amount: amount,
        receipient: %Client{email: email, first_name: receipient_first_name},
        sender: %Client{first_name: sender_first_name},
        sender_account: %BankAccount{name: account}
      } = request

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
      |> Mailer.deliver_later()

      nil
    end

    defp base_email,
      do:
        new_email()
        |> from("faux_banker@invento.io")
  end
end
