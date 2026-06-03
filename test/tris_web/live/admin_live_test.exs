defmodule TrisWeb.AdminLiveTest do
  use TrisWeb.ConnCase, async: false

  import Phoenix.LiveViewTest

  defp admin_password, do: Application.get_env(:tris, :admin_password, "admin")

  describe "authentication" do
    test "redirects unauthenticated requests to auth prompt", %{conn: conn} do
      conn = get(conn, ~p"/admin")
      assert conn.status == 401
      assert Plug.Conn.get_resp_header(conn, "www-authenticate") != []
    end

    test "renders admin dashboard with valid credentials", %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "Basic " <> Base.encode64("admin:#{admin_password()}"))

      {:ok, _view, html} = live(conn, ~p"/admin")
      assert html =~ "Admin Dashboard"
    end

    test "rejects invalid credentials", %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "Basic " <> Base.encode64("admin:wrongpass"))

      conn = get(conn, ~p"/admin")
      assert conn.status == 401
    end
  end

  describe "dashboard rendering" do
    test "shows stat cards", %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "Basic " <> Base.encode64("admin:#{admin_password()}"))

      {:ok, _view, html} = live(conn, ~p"/admin")
      assert html =~ "Users Online"
      assert html =~ "Active Games"
      assert html =~ "In Lobby"
      assert html =~ "In Queue"
    end

    test "shows empty state when no games are active", %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "Basic " <> Base.encode64("admin:#{admin_password()}"))

      {:ok, _view, html} = live(conn, ~p"/admin")
      assert html =~ "No active games"
    end

    test "shows game type breakdown", %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "Basic " <> Base.encode64("admin:#{admin_password()}"))

      {:ok, _view, html} = live(conn, ~p"/admin")
      assert html =~ "Human vs Human"
      assert html =~ "Bot Games"
    end

    test "shows player stats", %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "Basic " <> Base.encode64("admin:#{admin_password()}"))

      {:ok, _view, html} = live(conn, ~p"/admin")
      assert html =~ "In Lobby"
      assert html =~ "In Games"
      assert html =~ "Waiting in Queue"
    end
  end
end
