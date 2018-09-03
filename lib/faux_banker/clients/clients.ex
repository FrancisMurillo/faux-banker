defmodule FauxBanker.Clients do
  @moduledoc false

  alias __MODULE__, as: Context

  alias Comeonin.Bcrypt, as: Comeonin
  alias Ecto.Changeset

  alias FauxBanker.Repo

  alias Context.Client

  defmodule Queries do
    @moduledoc nil

    import Ecto.Query, warn: false

    def select_clients(),
      do: from(c in Client, where: c.role == ^:client)
  end

  def list_clients(),
    do: Context.Queries.select_clients() |> Repo.all()

  def get_client_by_code(code),
    do: Repo.get_by(Client, code: code, role: :client)
end
