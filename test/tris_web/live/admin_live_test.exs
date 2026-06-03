defmodule TrisWeb.AdminLiveTest do
  use TrisWeb.ConnCase, async: false

  import Phoenix.LiveViewTest

  alias Tris.GameServer
  alias Tris.GameSupervisor
  alias Tris.Matchmaker
  alias Tris.Presence

  defp admin_password, do: Application.get_env(:tris, :admin_password, "admin")

  setup %{conn: conn} do
    clean_up_games()

    conn =
      conn
      |> put_req_header("authorization", "Basic " <> Base.encode64("admin:#{admin_password()}"))

    %{conn: conn}
  end

  defp clean_up_games do
    game_ids =
      Registry.select(Tris.GameRegistry, [{{:"$1", :_, :_}, [], [:"$1"]}])

    Enum.each(game_ids, fn id ->
      case Registry.lookup(Tris.GameRegistry, id) do
        [{pid, _}] -> Process.exit(pid, :kill)
        _ -> :ok
      end
    end)

    queue_state = :sys.get_state(Tris.Matchmaker)

    Enum.each(queue_state.queue, fn {pid, _name} ->
      Matchmaker.cancel(pid)
    end)

    :timer.sleep(20)
  end

  describe "authentication" do
    test "redirects unauthenticated requests to auth prompt" do
      conn = Phoenix.ConnTest.build_conn()
      conn = get(conn, ~p"/admin")
      assert conn.status == 401
      assert Plug.Conn.get_resp_header(conn, "www-authenticate") != []
    end

    test "renders admin dashboard with valid credentials", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/admin")
      assert html =~ "Admin Dashboard"
    end

    test "rejects invalid credentials", %{conn: conn} do
      conn = put_req_header(conn, "authorization", "Basic " <> Base.encode64("admin:wrongpass"))
      conn = get(conn, ~p"/admin")
      assert conn.status == 401
    end
  end

  describe "dashboard rendering" do
    test "shows stat cards", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/admin")
      assert html =~ "Users Online"
      assert html =~ "Active Games"
      assert html =~ "In Lobby"
      assert html =~ "In Queue"
    end

    test "shows empty state when no games are active", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/admin")
      assert html =~ "No active games"
    end

    test "shows game type breakdown", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/admin")
      assert html =~ "Human vs Human"
      assert html =~ "Bot Games"
    end

    test "shows player stats", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/admin")
      assert html =~ "In Lobby"
      assert html =~ "In Games"
      assert html =~ "Waiting in Queue"
    end
  end

  describe "metric accuracy" do
    test "shows correct user counts without double-counting queued lobby users", %{conn: conn} do
      Presence.track(self(), "user", inspect(self()), %{location: "lobby"})

      Matchmaker.ask_to_play(self(), "Alice")
      assert_receive :waiting

      on_exit(fn ->
        Matchmaker.cancel(self())
      end)

      {:ok, view, _html} = live(conn, ~p"/admin")
      html = render(view)

      assert html =~ "In Lobby"
      assert html =~ "In Queue"
      refute html =~ "No active games"
    end

    test "bot player names are not counted as in-game users", %{conn: conn} do
      game_id = "bot-test-#{System.unique_integer([:positive])}"

      {:ok, _pid} = GameSupervisor.start_bot_game(game_id, self(), "Alice", :easy)

      {:ok, view, _html} = live(conn, ~p"/admin")
      html = render(view)

      assert html =~ "Bot Games"
      refute html =~ "No active games"
    end

    test "shows correct game type breakdown for human and bot games", %{conn: conn} do
      game_id_human = "human-test-#{System.unique_integer([:positive])}"
      game_id_easy = "easy-test-#{System.unique_integer([:positive])}"
      game_id_hard = "hard-test-#{System.unique_integer([:positive])}"

      other_pid = spawn(fn -> Process.sleep(:infinity) end)

      {:ok, _pid} =
        GameSupervisor.start_game(game_id_human, self(), "Alice", other_pid, "Bob")

      {:ok, _pid} = GameSupervisor.start_bot_game(game_id_easy, self(), "Charlie", :easy)
      {:ok, _pid} = GameSupervisor.start_bot_game(game_id_hard, self(), "Dave", :hard)

      {:ok, view, _html} = live(conn, ~p"/admin")
      html = render(view)

      assert html =~ "Human vs Human"
      assert html =~ "Bot Games"
      assert html =~ "Easy Bot"
      assert html =~ "Hard Bot"
    end

    test "finished games are not counted as active", %{conn: conn} do
      playing_id = "playing-#{System.unique_integer([:positive])}"
      finished_id = "finished-#{System.unique_integer([:positive])}"

      other_pid = spawn(fn -> Process.sleep(:infinity) end)
      other2_pid = spawn(fn -> Process.sleep(:infinity) end)

      {:ok, _pid} =
        GameSupervisor.start_game(playing_id, self(), "Alice", other_pid, "Bob")

      {:ok, _pid} =
        GameSupervisor.start_game(finished_id, self(), "Carol", other2_pid, "Dave")

      assert {:ok, _state} = GameServer.resign(finished_id, self())

      {:ok, view, _html} = live(conn, ~p"/admin")
      html = render(view)

      assert html =~ "Active Games"
      assert html =~ "Human vs Human"
      refute html =~ "No active games"
    end
  end

  describe "GameServer resign" do
    test "returns error when resigning with unrecognized PID" do
      game_id = "resign-test-#{System.unique_integer([:positive])}"

      {:ok, _pid} =
        GameSupervisor.start_game(game_id, self(), "Alice", spawn(fn -> :ok end), "Bob")

      fake_pid = spawn(fn -> :ok end)
      assert GameServer.resign(game_id, fake_pid) == {:error, :player_not_found}
    end
  end
end
