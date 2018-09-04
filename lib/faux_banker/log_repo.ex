defmodule FauxBanker.LogRepo do
  @moduledoc nil

  use Ecto.Repo, otp_app: :faux_banker

  def init(_, opts) do
    {:ok, Keyword.put(opts, :url, System.get_env("DATABASE_URL"))}
  end
end
