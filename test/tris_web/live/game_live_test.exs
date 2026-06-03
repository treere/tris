defmodule TrisWeb.GameLiveTest do
  use TrisWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  setup do
    game_id = "test-game-#{System.unique_integer([:positive])}"

    start_supervised!(
      {Tris.GameServer,
       %{
         game_id: game_id,
         player1_pid: self(),
         player1_name: "Alice",
         player2_pid: :dummy_pid,
         player2_name: "Bob"
       }}
    )

    %{game_id: game_id}
  end

  test "shows Your turn badge when it's the player's turn", %{conn: conn, game_id: game_id} do
    {:ok, view, _html} = live(conn, ~p"/game/#{game_id}?m=x")

    assert has_element?(view, "span", "Your turn")
  end

  test "shows Waiting for opponent when it's not the player's turn", %{
    conn: conn,
    game_id: game_id
  } do
    {:ok, view, _html} = live(conn, ~p"/game/#{game_id}?m=o")

    assert has_element?(view, "span", "Waiting for opponent...")
  end

  test "shows You label for the current player", %{conn: conn, game_id: game_id} do
    {:ok, view, _html} = live(conn, ~p"/game/#{game_id}?m=x")

    html = render(view)
    assert html =~ "You"
    assert html =~ "(x)"
  end

  test "shows opponent name when it is not the player", %{conn: conn, game_id: game_id} do
    {:ok, view, _html} = live(conn, ~p"/game/#{game_id}?m=o")

    html = render(view)
    assert html =~ "Alice"
    assert html =~ "(x)"
  end

  test "board has dimmed styling when not player's turn", %{conn: conn, game_id: game_id} do
    {:ok, view, _html} = live(conn, ~p"/game/#{game_id}?m=o")

    html = render(view)
    assert html =~ "opacity-50"
    assert html =~ "pointer-events-none"
  end

  test "board has full opacity when it is player's turn", %{conn: conn, game_id: game_id} do
    {:ok, view, _html} = live(conn, ~p"/game/#{game_id}?m=x")

    html = render(view)
    refute html =~ "opacity-50"
  end

  test "shows Waiting text for inactive player", %{conn: conn, game_id: game_id} do
    {:ok, view, _html} = live(conn, ~p"/game/#{game_id}?m=x")

    assert has_element?(view, "span", "Waiting...")
  end

  describe "game over redirect" do
    test "shows result and redirect text when game ends", %{conn: conn, game_id: game_id} do
      {:ok, view, _html} = live(conn, ~p"/game/#{game_id}?m=x")

      game_state = Tris.GameServer.get_state(game_id)

      send(
        view.pid,
        {:game_update,
         %{game_state | status: :won, winner: :x, winning_cells: [{0, 0}, {0, 1}, {0, 2}]}}
      )

      html = render(view)
      assert html =~ "Alice wins!"
      assert html =~ "Redirecting to lobby..."
      assert has_element?(view, "button", "Return to lobby")
    end

    test "shows tie text when game ends in tie", %{conn: conn, game_id: game_id} do
      {:ok, view, _html} = live(conn, ~p"/game/#{game_id}?m=x")

      state = Tris.GameServer.get_state(game_id)
      send(view.pid, {:game_update, %{state | status: :tie}})

      html = render(view)
      assert html =~ "tie!"
    end

    test "return_to_lobby navigates to lobby", %{conn: conn, game_id: game_id} do
      {:ok, view, _html} = live(conn, ~p"/game/#{game_id}?m=x")

      game_state = Tris.GameServer.get_state(game_id)

      send(
        view.pid,
        {:game_update,
         %{game_state | status: :won, winner: :x, winning_cells: [{0, 0}, {0, 1}, {0, 2}]}}
      )

      render(view)

      view |> element("button", "Return to lobby") |> render_click()

      assert_redirect(view, ~p"/")
    end
  end

  describe "chat in human vs human game" do
    test "shows chat panel for human games", %{conn: conn, game_id: game_id} do
      {:ok, view, _html} = live(conn, ~p"/game/#{game_id}?m=x")

      assert has_element?(view, "#chat-form")
      assert has_element?(view, "div", "Chat")
    end

    test "submitting chat message displays it", %{conn: conn, game_id: game_id} do
      {:ok, view, _html} = live(conn, ~p"/game/#{game_id}?m=x")

      view
      |> element("#chat-form")
      |> render_submit(%{"text" => "Hello there!"})

      html = render(view)
      assert html =~ "Hello there!"
    end
  end

  describe "bot game display" do
    setup do
      bot_game_id = "bot-game-#{System.unique_integer([:positive])}"

      start_supervised!(
        {Tris.GameServer,
         %{
           game_id: bot_game_id,
           player1_pid: self(),
           player1_name: "Human",
           player2_pid: :bot,
           player2_name: "Bot (Hard)",
           bot_difficulty: :hard
         }},
        id: :bot_game_live
      )

      %{game_id: bot_game_id}
    end

    test "shows bot opponent name", %{conn: conn, game_id: game_id} do
      {:ok, view, _html} = live(conn, ~p"/game/#{game_id}?m=x")

      html = render(view)
      assert html =~ "Bot (Hard)"
    end

    test "does not show chat panel for bot games", %{conn: conn, game_id: game_id} do
      {:ok, view, _html} = live(conn, ~p"/game/#{game_id}?m=x")

      refute has_element?(view, "#chat-form")
    end
  end

  describe "resign" do
    test "shows resign button when game is playing", %{conn: conn, game_id: game_id} do
      {:ok, view, _html} = live(conn, ~p"/game/#{game_id}?m=x")

      assert has_element?(view, "button", "Resign")
    end

    test "shows confirmation modal when resign button is clicked", %{conn: conn, game_id: game_id} do
      {:ok, view, _html} = live(conn, ~p"/game/#{game_id}?m=x")

      view |> element("button", "Resign") |> render_click()

      assert has_element?(view, "p", "Are you sure you want to resign?")
      assert has_element?(view, "button", "Cancel")
      assert has_element?(view, "button", "Confirm, resign")
    end

    test "hides modal when cancel is clicked", %{conn: conn, game_id: game_id} do
      {:ok, view, _html} = live(conn, ~p"/game/#{game_id}?m=x")

      view |> element("button", "Resign") |> render_click()
      assert has_element?(view, "#resign-modal")
      refute has_element?(view, "#resign-modal.hidden")

      view |> element("button", "Cancel") |> render_click()

      assert has_element?(view, "#resign-modal.hidden")
    end

    test "shows resign result message after confirming", %{conn: conn, game_id: game_id} do
      {:ok, view, _html} = live(conn, ~p"/game/#{game_id}?m=x")

      view |> element("button", "Resign") |> render_click()
      view |> element("button", "Confirm, resign") |> render_click()

      html = render(view)
      assert html =~ "Alice resigned!"
      assert has_element?(view, "button", "Return to lobby")
    end

    test "shows resign message for opponent player", %{conn: conn, game_id: game_id} do
      {:ok, view, _html} = live(conn, ~p"/game/#{game_id}?m=o")

      game_state = Tris.GameServer.get_state(game_id)
      send(view.pid, {:game_update, %{game_state | status: :won, winner: :o, resigned_by: :x}})

      html = render(view)
      assert html =~ "Alice resigned!"
    end
  end

  describe "turn timer" do
    test "shows countdown when it's the player's turn", %{conn: conn, game_id: game_id} do
      {:ok, view, _html} = live(conn, ~p"/game/#{game_id}?m=x")

      assert has_element?(view, "span", "30s")
    end

    test "shows timeout message when game ends due to timeout", %{conn: conn, game_id: game_id} do
      {:ok, view, _html} = live(conn, ~p"/game/#{game_id}?m=x")

      game_state = Tris.GameServer.get_state(game_id)

      send(
        view.pid,
        {:game_update,
         %{
           game_state
           | status: :won,
             winner: :o,
             timeout_player: :x,
             turn_started_at: nil,
             timer_ref: nil
         }}
      )

      html = render(view)
      assert html =~ "Alice ran out of time!"
    end
  end

  describe "nonexistent game" do
    test "shows game not found page for invalid game ID", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/game/nonexistent-123")

      assert has_element?(view, "div", "Game not found")
      assert has_element?(view, "p", "This game does not exist or has already ended.")
      assert has_element?(view, "p", "Redirecting to lobby...")
    end

    test "valid game still renders normally", %{conn: conn, game_id: game_id} do
      {:ok, view, _html} = live(conn, ~p"/game/#{game_id}?m=x")

      refute has_element?(view, "div", "Game not found")
      assert has_element?(view, "span", "Your turn")
    end
  end
end
