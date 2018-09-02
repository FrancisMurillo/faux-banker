defmodule FauxBanker.DataCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the application's data layer.

  You may define functions here to be used as helpers in
  your tests.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias FauxBanker.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import FauxBanker.DataCase
    end
  end

  setup tags do
    {:ok, event_store} = Commanded.EventStore.Adapters.InMemory.start_link()

    {:ok, _} = Application.ensure_all_started(:ecto)
    {:ok, _} = Application.ensure_all_started(:commanded)

    {:ok, _} = Application.ensure_all_started(:faux_banker)

    on_exit(fn ->
      Application.stop(:commanded)

      Application.stop(:faux_banker)

      Commanded.Helpers.ProcessHelper.shutdown(event_store)
    end)

    :ok = Ecto.Adapters.SQL.Sandbox.checkout(FauxBanker.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(FauxBanker.Repo, {:shared, self()})
    end

    :ok
  end

  @doc """
  A helper that transform changeset errors to a map of messages.

      assert {:error, changeset} = Accounts.create_user(%{password: "short"})
      assert "password is too short" in errors_on(changeset).password
      assert %{password: ["password is too short"]} = errors_on(changeset)

  """
  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Enum.reduce(opts, message, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
