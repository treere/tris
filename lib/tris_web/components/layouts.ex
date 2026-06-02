defmodule TrisWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use TrisWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <main class="px-4 py-8 sm:px-6 lg:px-8">
      <div class="mx-auto max-w-2xl">
        <div class="flex justify-end mb-4">
          <.theme_selector />
        </div>
        {render_slot(@inner_block)}
      </div>
    </main>

    <.flash_group flash={@flash} />
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Theme selector dropdown showing all available themes with color swatches.
  """
  attr :themes, :list,
    default: [
      %{id: "phoenix", label: "Phoenix", color: "oklch(70% 0.213 47.604)"},
      %{id: "elixir", label: "Elixir", color: "oklch(58% 0.233 277.117)"},
      %{id: "forest", label: "Forest", color: "oklch(50% 0.2 145)"},
      %{id: "ocean", label: "Ocean", color: "oklch(48% 0.22 260)"},
      %{id: "sunset", label: "Sunset", color: "oklch(60% 0.22 30)"},
      %{id: "midnight", label: "Midnight", color: "oklch(55% 0.22 280)"}
    ]

  def theme_selector(assigns) do
    ~H"""
    <div class="dropdown dropdown-end">
      <button class="btn btn-ghost btn-sm rounded-full" aria-label="Choose theme">
        <.icon name="hero-swatch-micro" class="size-4" />
      </button>
      <div class="dropdown-content card card-sm bg-base-100 border border-base-300 shadow-lg mt-2 p-2 min-w-40">
        <div class="flex flex-col gap-0.5">
          <div :for={theme <- @themes}>
            <button
              phx-click={JS.dispatch("phx:set-theme")}
              data-phx-theme={theme.id}
              class="flex items-center gap-2 w-full px-3 py-1.5 rounded-box hover:bg-base-200 text-sm"
            >
              <span class="size-3 rounded-full shrink-0" style={"background: #{theme.color}"} />
              {theme.label}
            </button>
          </div>
        </div>
        <div class="divider my-1"></div>
        <button
          phx-click={JS.dispatch("phx:set-theme")}
          data-phx-theme="system"
          class="flex items-center gap-2 w-full px-3 py-1.5 rounded-box hover:bg-base-200 text-sm"
        >
          <.icon name="hero-computer-desktop-micro" class="size-3 shrink-0" /> System
        </button>
      </div>
    </div>
    """
  end
end
