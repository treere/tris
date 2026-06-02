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
end
