defmodule FauxBanker.Accounts do
  @moduledoc false

  alias __MODULE__, as: Context

  alias Comeonin.Bcrypt, as: Comeonin
  alias Ecto.Changeset

  alias FauxBanker.Repo

  alias Context.User

  defmodule Queries do
    @moduledoc false

    import Ecto.Query, warn: false

    def find_user_by_email_or_username(email_or_username) do
      from(u in User,
        where:
          u.email == ^email_or_username or u.username == ^email_or_username,
        limit: 1
      )
    end
  end

  def register_client(%{} = attrs) do
    %User{}
    |> User.register_client_changeset(attrs)
    |> Repo.insert()
    |> case do
      {:error, %Changeset{valid?: false} = errors} ->
        {:error, errors}

      {:ok, entity} ->
        {:ok, entity}
    end
  end

  def get_user_by_email(email),
    do: Repo.get_by(User, email: email)

  def get_user(id),
    do: Repo.get(User, id)

  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  def find_user_by_authentication(%{} = attrs) do
    email = Map.get(attrs, "email", nil) || Map.get(attrs, :email, nil)
    username = Map.get(attrs, "username", nil) || Map.get(attrs, :username, nil)

    password =
      Map.get(attrs, "password", nil) || Map.get(attrs, :password) || ""

    (email || username || "")
    |> Context.Queries.find_user_by_email_or_username()
    |> Repo.one()
    |> case do
      nil ->
        {:error, :invalid_auth}

      %User{password_hash: password_hash} = user ->
        if(Comeonin.checkpw(password, password_hash),
          do: {:ok, user},
          else: {:error, :invalid_auth}
        )
    end
  end
end
