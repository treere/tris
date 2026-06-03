defmodule TrisWeb.LobbyLiveTest do
  use TrisWeb.ConnCase, async: false

  import Phoenix.LiveViewTest

  test "renders username form", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")
    assert has_element?(view, "#username-form")
  end

  test "shows ask to play after setting username", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view
    |> element("#username-form")
    |> render_submit(%{user: %{username: "testplayer"}})

    assert has_element?(view, "button", "Ask to play")
  end

  test "shows bot buttons after setting username", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view
    |> element("#username-form")
    |> render_submit(%{user: %{username: "testplayer"}})

    assert has_element?(view, "button", "Bot (Easy)")
    assert has_element?(view, "button", "Bot (Hard)")
  end

  test "shows waiting status after asking to play", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view
    |> element("#username-form")
    |> render_submit(%{user: %{username: "testplayer"}})

    view |> element("button", "Ask to play") |> render_click()
    assert has_element?(view, "button", "Cancel")
  end

  test "shows Change name button after setting username", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view
    |> element("#username-form")
    |> render_submit(%{user: %{username: "testplayer"}})

    assert has_element?(view, "button", "Change name")
  end

  test "Change name returns to username form", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view
    |> element("#username-form")
    |> render_submit(%{user: %{username: "testplayer"}})

    view |> element("button", "Change name") |> render_click()

    assert has_element?(view, "#username-form")
  end

  test "restores username from hook event", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    render_hook(view, "restore_username", %{username: "Alice"})

    assert has_element?(view, "button", "Ask to play")
    assert has_element?(view, "button", "Change name")
  end

  test "shows credits link", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")
    assert has_element?(view, "a", "Credits")
  end
end
