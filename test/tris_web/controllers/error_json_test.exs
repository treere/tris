defmodule TrisWeb.ErrorJSONTest do
  use TrisWeb.ConnCase, async: true

  test "renders 404" do
    assert TrisWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert TrisWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
