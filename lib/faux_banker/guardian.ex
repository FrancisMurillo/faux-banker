defmodule FauxBanker.Guardian do
  @moduledoc nil

  use Guardian, otp_app: :faux_banker

  alias FauxBanker.Repo
  alias FauxBanker.Accounts
  alias FauxBanker.Accounts.User

  def subject_for_token(%{email: email}, _claims) do
    case Accounts.get_user_by_email(email) do
      nil ->
        {:error, :invalid_resource}

      %User{id: id} ->
        {:ok, id}
    end
  end

  def resource_from_claims(claims) do
    id = claims["sub"]

    case Accounts.get_user(id) do
      nil ->
        {:error, :invalid_resource}

      user ->
        {:ok, user}
    end
  end
end
