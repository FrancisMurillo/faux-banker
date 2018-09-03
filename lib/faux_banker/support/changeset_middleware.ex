defmodule FauxBanker.Support.ChangesetMiddleware do
  @moduledoc nil
  @behaviour Commanded.Middleware

  import Commanded.Middleware.Pipeline
  import Ecto.Changeset
  alias Commanded.Middleware.Pipeline
  alias Ecto.Changeset

  def before_dispatch(%Pipeline{command: command} = pipeline) do
    case command |> IO.inspect(label: "comm") do
      %Changeset{valid?: false} = changeset ->
        pipeline
        |> respond({:error, changeset})
        |> halt

      %Changeset{valid?: true} = changeset ->
        valid_command = apply_changes(changeset)

        pipeline
        |> Map.put(:command, valid_command)

      _ ->
        pipeline
    end
  end

  def after_dispatch(pipeline), do: pipeline
  def after_failure(pipeline), do: pipeline
end
