defmodule FauxBanker.AccountsTest do
  use FauxBanker.DataCase

  alias Comeonin.Bcrypt, as: Comeonin
  alias Ecto.Changeset

  import FauxBanker.Factory

  alias FauxBanker.Accounts, as: Context
  alias Context.User

  describe "Context.register_client/1" do
    @tag :positive
    test "should work and only once" do
      params = string_params_for(:user, %{})

      assert {:ok, %User{role: :client}} = Context.register_client(params)
      assert {:error, %Changeset{}} = Context.register_client(params)
    end

    @tag :negative
    test "should fail safely" do
      assert {:error, %Changeset{}} = Context.register_client(%{})
    end
  end

  describe "Context.find_user_by_authentication/1" do
    setup do
      %{
        user:
          :user
          |> insert(%{
            password: "123456",
            password_hash: Comeonin.hashpwsalt("123456")
          })
      }
    end

    @tag :positive
    @tag :negative
    @tag :wip
    test "should work and fail safely", %{
      user: %User{id: id, username: username, email: email, password: password}
    } do
      assert {:error, :invalid_auth} = Context.find_user_by_authentication(%{})

      assert {:error, :invalid_auth} =
               Context.find_user_by_authentication(%{username: username})

      assert {:error, :invalid_auth} =
               Context.find_user_by_authentication(%{email: email})

      assert {:error, :invalid_auth} =
               Context.find_user_by_authentication(%{password: email})

      assert {:error, :invalid_auth} =
               Context.find_user_by_authentication(%{
                 username: username,
                 email: email
               })

      assert {:ok, %User{id: ^id}} =
               Context.find_user_by_authentication(%{
                 email: email,
                 password: password
               })

      assert {:ok, %User{id: ^id}} =
               Context.find_user_by_authentication(%{
                 username: username,
                 password: password
               })
    end
  end
end
