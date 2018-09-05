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
      RequestMade,
      RequestApproved,
      RequestRejected
    }

    defstruct []

    def interested?(%RequestMade{id: id}),
      do: {:start, id}

    def interested?(%RequestApproved{id: id}),
      do: {:continue, id}

    def interested?(%RequestRejected{id: id}),
      do: {:continue, id}

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

    def request_approved_email(%AccountRequest{} = request) do
      %AccountRequest{
        receipient_reason: reason,
        amount: amount,
        receipient: %{first_name: receipient_first_name},
        sender: %{email: email, first_name: sender_first_name},
        sender_account: %BankAccount{name: account}
      } =
        request
        |> Repo.preload([:sender, :receipient, :sender_account])

      base_email()
      |> to(email)
      |> subject("Request Approved")
      |> text_body("""
      Hello #{sender_first_name},

      Your friend, #{receipient_first_name}, approved your request and transfered  #{
        Decimal.round(amount)
      } to your account, #{account}. and says...

      #{reason}

      Go back to the site and check it out.
      """)
    end

    def handle(_state, %RequestApproved{id: id}) do
      if request = Repo.get(AccountRequest, id) do
        request
        |> request_approved_email()
        |> Mailer.deliver_later()

        nil
      else
        {:error, :request_not_found}
      end
    end

    def request_rejected_email(%AccountRequest{} = request) do
      %AccountRequest{
        receipient_reason: reason,
        amount: amount,
        receipient: %{first_name: receipient_first_name},
        sender: %{email: email, first_name: sender_first_name},
        sender_account: %BankAccount{name: account}
      } =
        request
        |> Repo.preload([:sender, :receipient, :sender_account])

      base_email()
      |> to(email)
      |> subject("Request Rejected")
      |> text_body("""
      Hello #{sender_first_name},

      Your friend, #{receipient_first_name}, rejected your request to your account, #{
        account
      }. and says...

      #{reason}

      Go back to the site and check it out.
      """)
    end

    def handle(_state, %RequestRejected{id: id}) do
      if request = Repo.get(AccountRequest, id) do
        request
        |> request_rejected_email()
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
