defmodule FauxBanker.Clients do
  @moduledoc false

  alias __MODULE__, as: Context

  alias FauxBanker.Repo

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

  def list_client_friends(client_id),
    do: client_id |> Context.Queries.select_client_friends() |> Repo.all()

  def get_client_by_code(code),
    do: Repo.get_by(Client, code: code, role: :client)
end
