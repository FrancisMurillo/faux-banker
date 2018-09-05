defmodule FauxBanker.Clients do
  @moduledoc false

  alias FauxBanker.Repo

  alias __MODULE__, as: Context

  alias FauxBanker.Accounts.User

  alias Context.Client

  defmodule Queries do
    @moduledoc nil

    import Ecto.Query, warn: false

    def select_clients(),
      do: from(c in Client, where: c.role == ^:client)

    def select_client_friends(client_id),
      do: from(c in Client, where: c.role == ^:client and c.id != ^client_id)
  end

  def list_clients(),
    do: Context.Queries.select_clients() |> Repo.all()

  def list_client_friends_by_id(client_id),
    do: client_id |> Context.Queries.select_client_friends() |> Repo.all()

  def get_client_by_code(code),
    do: Client |> Repo.get_by(code: code, role: :client)

  def user_as_client(%User{role: :client} = user),
    do: {:ok, struct(Client, Map.from_struct(user))}

  def user_as_client(_),
    do: {:error, :invalid_user}
end
