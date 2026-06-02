defmodule TrisWeb.LobbyLive do
  use TrisWeb, :live_view

  alias Tris.Matchmaker

  def mount(%{"username" => username}, _session, socket) when byte_size(username) > 0 do
    socket =
      socket
      |> assign(:username, username)
      |> assign(:show_form, false)
      |> assign(:queue_status, nil)
      |> assign(:form, to_form(%{"username" => ""}, as: :user))

    {:ok, socket}
  end

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:username, nil)
      |> assign(:show_form, true)
      |> assign(:queue_status, nil)
      |> assign(:form, to_form(%{"username" => ""}, as: :user))

    {:ok, socket}
  end

  def handle_event("set_username", %{"user" => %{"username" => username}}, socket) do
    username = String.trim(username)

    cond do
      username == "" ->
        socket =
          socket
          |> put_flash(:error, "Username cannot be empty")
          # simplified
          |> assign(
            :form,
            to_form(%{"username" => ""}, as: :user, errors: [username: {"can't be blank", []}])
          )

        {:noreply, socket}

      String.length(username) > 20 ->
        {:noreply,
         assign(socket, :form, to_form(%{"username" => ""}, as: :user))
         |> put_flash(:error, "Username too long (max 20 characters)")}

      not String.match?(username, ~r/^[a-zA-Z0-9_]+$/) ->
        {:noreply,
         assign(socket, :form, to_form(%{"username" => ""}, as: :user))
         |> put_flash(:error, "Username can only contain letters, numbers, and underscores")}

      true ->
        socket =
          socket
          |> assign(:username, username)
          |> assign(:show_form, false)
          |> assign(:queue_status, nil)

        {:noreply, socket}
    end
  end

  def handle_event("ask_to_play", _, socket) do
    case Matchmaker.ask_to_play(self(), socket.assigns.username) do
      :waiting ->
        {:noreply, assign(socket, :queue_status, :waiting)}

      {:matched, game_id, mark, my_name, opponent_name} ->
        socket =
          socket
          |> assign(:queue_status, :matched)
          |> push_navigate(to: "/game/#{game_id}?m=#{mark}&n=#{my_name}&o=#{opponent_name}")

        {:noreply, socket}
    end
  end

  def handle_event("play_with_bot", %{"difficulty" => difficulty}, socket) do
    {:matched, game_id, mark, my_name, opponent_name} =
      Matchmaker.play_with_bot(
        self(),
        socket.assigns.username,
        String.to_existing_atom(difficulty)
      )

    {:noreply,
     socket
     |> push_navigate(to: "/game/#{game_id}?m=#{mark}&n=#{my_name}&o=#{opponent_name}")}
  end

  def handle_event("change_name", _, socket) do
    Matchmaker.cancel(self())

    {:noreply,
     socket
     |> assign(:username, nil)
     |> assign(:show_form, true)
     |> assign(:queue_status, nil)
     |> assign(:form, to_form(%{"username" => ""}, as: :user))}
  end

  def handle_event("cancel_queue", _, socket) do
    Matchmaker.cancel(self())
    {:noreply, assign(socket, :queue_status, nil)}
  end

  def handle_info(:waiting, socket) do
    {:noreply, assign(socket, :queue_status, :waiting)}
  end

  def handle_info({:matched, game_id, mark, my_name, opponent_name}, socket) do
    socket =
      socket
      |> assign(:queue_status, :matched)
      |> push_navigate(to: "/game/#{game_id}?m=#{mark}&n=#{my_name}&o=#{opponent_name}")

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="mx-auto max-w-lg">
        <div class="text-center mb-8">
          <h1 class="text-4xl font-bold tracking-tight">Tris</h1>
          <p class="mt-2 text-base-content/60">Online Tic-Tac-Toe</p>
        </div>

        <%= if @show_form do %>
          <div class="card bg-base-200 p-6 rounded-box">
            <h2 class="text-lg font-semibold mb-4">Choose your username</h2>
            <.form for={@form} id="username-form" phx-submit="set_username">
              <.input
                field={@form[:username]}
                type="text"
                placeholder="Enter username..."
                class="input input-bordered w-full"
              />
              <button type="submit" class="btn btn-primary mt-4 w-full">
                Set Username
              </button>
            </.form>
          </div>
        <% else %>
          <div class="card bg-base-200 p-6 rounded-box">
            <div class="flex items-center justify-between mb-4">
              <h2 class="text-lg font-semibold">Welcome, {@username}</h2>
              <button phx-click="change_name" class="btn btn-ghost btn-sm">
                Change name
              </button>
            </div>

            <%= cond do %>
              <% @queue_status == :waiting -> %>
                <div class="text-center py-8">
                  <div class="loading loading-spinner loading-lg mb-4"></div>
                  <p class="text-base-content/70">Waiting for opponent...</p>
                  <button phx-click="cancel_queue" class="btn btn-ghost mt-4">
                    Cancel
                  </button>
                </div>
              <% @queue_status == :matched -> %>
                <div class="text-center py-8">
                  <div class="loading loading-spinner loading-lg mb-4"></div>
                  <p class="text-base-content/70">Match found! Joining game...</p>
                </div>
              <% true -> %>
                <div class="text-center py-8 space-y-4">
                  <button phx-click="ask_to_play" class="btn btn-primary btn-lg w-full">
                    Ask to play
                  </button>
                  <div class="divider text-base-content/40 text-xs uppercase tracking-wider font-semibold">
                    or play against
                  </div>
                  <div class="flex gap-3">
                    <button
                      phx-click="play_with_bot"
                      phx-value-difficulty="easy"
                      class="btn btn-outline btn-lg flex-1"
                    >
                      Bot (Easy)
                    </button>
                    <button
                      phx-click="play_with_bot"
                      phx-value-difficulty="hard"
                      class="btn btn-outline btn-lg flex-1"
                    >
                      Bot (Hard)
                    </button>
                  </div>
                </div>
            <% end %>
          </div>
        <% end %>
      </div>
    </Layouts.app>
    """
  end
end
