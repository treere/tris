defmodule TrisWeb.CreditLiveTest do
  use TrisWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders credits page with heading", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/credits")
    assert has_element?(view, "h1", "Credits")
  end

  test "lists technologies used", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/credits")

    html = render(view)
    assert html =~ "Phoenix Framework"
    assert html =~ "Elixir"
    assert html =~ "Tailwind CSS"
    assert html =~ "daisyUI"
    assert html =~ "Heroicons"
  end

  test "has a link back to the lobby", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/credits")
    assert has_element?(view, "a", "Back to lobby")
  end
end
