defmodule TrisWeb.CreditLive do
  use TrisWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="mx-auto max-w-lg">
        <div class="text-center mb-8">
          <h1 class="text-4xl font-bold tracking-tight">Credits</h1>
        </div>

        <div class="space-y-6">
          <div class="card bg-base-200 p-6 rounded-box">
            <h2 class="text-lg font-semibold mb-3">Made by</h2>
            <ul class="space-y-2 text-base-content/80">
              <li>
                <a href="https://github.com/treere" class="link link-hover font-medium">treere</a>
                — built this in Elixir with ♥
              </li>
            </ul>
          </div>

          <div class="card bg-base-200 p-6 rounded-box">
            <h2 class="text-lg font-semibold mb-3">Built with</h2>
            <ul class="space-y-2 text-base-content/80">
              <li>
                <a href="https://phoenixframework.org" class="link link-hover font-medium">
                  Phoenix Framework
                </a>
                — real-time web framework for Elixir
              </li>
              <li>
                <a href="https://elixir-lang.org" class="link link-hover font-medium">Elixir</a>
                — functional, concurrent language on the Erlang VM
              </li>
              <li>
                <a href="https://tailwindcss.com" class="link link-hover font-medium">Tailwind CSS</a>
                — utility-first CSS framework
              </li>
              <li>
                <a href="https://daisyui.com" class="link link-hover font-medium">daisyUI</a>
                — Tailwind CSS component library
              </li>
              <li>
                <a href="https://heroicons.com" class="link link-hover font-medium">Heroicons</a>
                — SVG icon set
              </li>
            </ul>
          </div>

          <div class="text-center">
            <.link navigate="/" class="link link-hover text-sm text-base-content/50">
              &larr; Back to lobby
            </.link>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
