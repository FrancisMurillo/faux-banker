defmodule FauxBanker.AccountRequests do
  @moduledoc nil

  import Ecto.Changeset
  alias Ecto.Changeset
  alias UUID

  alias FauxBanker.{Repo, Router}

  alias FauxBanker.BankAccounts.BankAccount
  alias FauxBanker.Clients.Client

  alias __MODULE__, as: Context
  alias Context.Requests, as: RequestSubContext

  alias RequestSubContext.Commands.{MakeRequest, ApproveRequest, RejectRequest}

  alias Context.{AccountRequest}

  defmodule Queries do
    @moduledoc nil

    import Ecto.Query

    def select_client_requests(client_id),
      do:
        from(a in AccountRequest,
          inner_join: s in Client,
          on: s.id == a.sender_id,
          inner_join: sb in BankAccount,
          on: sb.id == a.sender_account_id,
          inner_join: r in Client,
          on: r.id == a.receipient_id,
          left_join: rb in BankAccount,
          on: rb.id == a.receipient_account_id,
          where: a.sender_id == ^client_id or a.receipient_id == ^client_id,
          order_by: [desc: :updated_at],
          preload: [
            sender: s,
            sender_account: sb,
            receipient: r,
            receipient_account: rb
          ]
        )
  end

  def list_client_requests_by_client_id(client_id),
    do: client_id |> Context.Queries.select_client_requests() |> Repo.all()

  def get_request_by_code(code),
    do: AccountRequest |> Repo.get_by(code: code)

  def make_client_request(%Client{} = client, attrs) do
    id = UUID.uuid4()

    case MakeRequest.changeset(%MakeRequest{id: id}, client, attrs) do
      %Changeset{valid?: false} = changeset ->
        {:error, changeset}

      changeset ->
        command = apply_changes(changeset)

        case Router.dispatch(command) do
          :ok ->
            if request = Repo.get(AccountRequest, id) do
              {:ok, request}
            else
              {:error, changeset}
            end

          error ->
            error
        end
    end
  end

  def approve_request(%AccountRequest{id: id} = request, attrs) do
    case ApproveRequest.changeset(%ApproveRequest{id: id}, request, attrs) do
      %Changeset{valid?: false} = changeset ->
        {:error, changeset}

      changeset ->
        command = apply_changes(changeset)

        case Router.dispatch(command) do
          :ok ->
            if request = Repo.get(AccountRequest, id) do
              {:ok, request}
            else
              {:error, changeset}
            end

          error ->
            error
        end
    end
  end

  def reject_request(%AccountRequest{id: id} = request, attrs) do
    case RejectRequest.changeset(%RejectRequest{id: id}, request, attrs) do
      %Changeset{valid?: false} = changeset ->
        {:error, changeset}

      changeset ->
        command = apply_changes(changeset)

        case Router.dispatch(command) do
          :ok ->
            if request = Repo.get(AccountRequest, id) do
              {:ok, request}
            else
              {:error, changeset}
            end

          error ->
            error
        end
    end
  end
end
