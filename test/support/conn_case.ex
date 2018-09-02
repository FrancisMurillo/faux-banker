defmodule FauxBankerWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common datastructures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest
      import FauxBankerWeb.Router.Helpers

      # The default endpoint for testing
      @endpoint FauxBankerWeb.Endpoint
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

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
