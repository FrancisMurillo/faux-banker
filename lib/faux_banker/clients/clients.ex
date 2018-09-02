defmodule FauxBanker.Clients do
  @moduledoc false

  alias __MODULE__, as: Context

  alias Comeonin.Bcrypt, as: Comeonin
  alias Ecto.Changeset

  alias FauxBanker.Repo

  alias Context.Client

  defmodule Queries do
    @moduledoc nil
  end

  def list_clients(),
    do: Repo.all(Client)
end
