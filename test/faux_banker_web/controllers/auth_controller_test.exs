defmodule FauxBankerWeb.AuthControllerTest do
  use FauxBankerWeb.ConnCase

  alias FauxBanker.Accounts

  describe "Controller" do
    @tag :positive
    test "signin form should work", %{conn: conn} do
      conn = get(conn, auth_path(conn, :signin_form))
      assert html_response(conn, 200)
    end

    @tag :positive
    @tag :negative
    test "signin should work", %{conn: conn} do
      fail_conn = post(conn, auth_path(conn, :callback), %{})
      assert redirected_to(conn, 302) =~ auth_path(conn, :signin_form)

      auth_conn = post(conn, auth_path(conn, :callback), %{})
      assert redirected_to(conn, 302) =~ auth_path(conn, :signin_form)
    end

    @tag :positive
    test "register client form should work", %{conn: conn} do
      conn = get(conn, auth_path(conn, :register_client_form))
      assert html_response(conn, 200)
    end

    @tag :positive
    @tag :negative
    test "register client should work", %{conn: conn} do
      fail_conn = post(conn, auth_path(conn, :callback), %{})
      assert redirected_to(conn, 302) =~ auth_path(conn, :signin_form)

      auth_conn = post(conn, auth_path(conn, :callback), %{})
      assert redirected_to(conn, 302) =~ auth_path(conn, :signin_form)
    end
  end
end
