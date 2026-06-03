defmodule TrisWeb.GameLive do
  use TrisWeb, :live_view

  alias Tris.GameServer
  alias Phoenix.PubSub

  @turn_timeout 30

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"id" => game_id} = params, _uri, socket) do
    PubSub.subscribe(Tris.PubSub, "game:#{game_id}")

    game_state = GameServer.get_state(game_id)

    player_mark =
      if params["m"] in ~w(x o) do
        mark = String.to_existing_atom(params["m"])
        GameServer.register_player(game_id, mark, self())
        mark
      end

    opponent_mark = player_mark && if(player_mark == :x, do: :o, else: :x)

    is_bot_game = game_state.bot_difficulty != nil

    socket =
      socket
      |> assign(:game_id, game_id)
      |> assign(:game_state, game_state)
      |> assign(:player_mark, player_mark)
      |> assign(:is_my_turn, game_state.turn == player_mark)
      |> assign(:is_bot_game, is_bot_game)
      |> assign(:is_human_game, not is_bot_game)
      |> assign(:chat_messages, game_state.chat_messages || [])
      |> assign(:my_name, game_state.names[player_mark] || params["n"])
      |> assign(:opponent_name, game_state.names[opponent_mark] || params["o"])
      |> assign(:result, nil)
      |> assign(:remaining_seconds, calc_remaining(game_state))
      |> assign(:show_resign_modal, false)
      |> assign(:chat_form, to_form(%{"text" => ""}))

    start_timer_tick(socket, game_state)

    {:noreply, socket}
  end

  def handle_info({:chat_message, message}, socket) do
    {:noreply, assign(socket, :chat_messages, socket.assigns.chat_messages ++ [message])}
  end

  def handle_info({:game_update, game_state}, socket) do
    previous_result = socket.assigns.result

    result =
      cond do
        game_state.status == :won and game_state.timeout_player ->
          "#{game_state.names[game_state.timeout_player]} ran out of time!"

        game_state.status == :won and game_state.resigned_by ->
          "#{game_state.names[game_state.resigned_by]} resigned!"

        game_state.status == :won ->
          "#{game_state.names[game_state.winner]} wins!"

        game_state.status == :tie ->
          "It's a tie!"

        true ->
          nil
      end

    socket =
      socket
      |> assign(:game_state, game_state)
      |> assign(:is_my_turn, game_state.turn == socket.assigns.player_mark)
      |> assign(:remaining_seconds, calc_remaining(game_state))
      |> assign(:result, result)

    if result != nil and previous_result == nil do
      Process.send_after(self(), :redirect_to_lobby, 5000)
    end

    {:noreply, socket}
  end

  def handle_info(:redirect_to_lobby, socket) do
    {:noreply, push_navigate(socket, to: ~p"/?username=#{socket.assigns.my_name}")}
  end

  def handle_info(:timer_tick, socket) do
    game_state = socket.assigns.game_state

    if game_state.status == :playing do
      remaining = calc_remaining(game_state)

      socket =
        if remaining != socket.assigns.remaining_seconds do
          assign(socket, :remaining_seconds, remaining)
        else
          socket
        end

      if remaining > 0 do
        Process.send_after(self(), :timer_tick, 1000)
      end

      {:noreply, socket}
    else
      {:noreply, assign(socket, :remaining_seconds, 0)}
    end
  end

  defp calc_remaining(game_state) do
    if game_state.turn_started_at do
      elapsed = System.monotonic_time() - game_state.turn_started_at
      elapsed_sec = div(elapsed, 1_000_000_000)
      max(0, @turn_timeout - elapsed_sec)
    else
      nil
    end
  end

  defp start_timer_tick(socket, game_state) do
    if game_state.status == :playing and game_state.turn_started_at != nil do
      Process.send_after(self(), :timer_tick, 1000)
    end

    socket
  end

  def handle_event("send_chat", %{"text" => text}, socket) do
    text = String.trim(text)

    if text != "" and not socket.assigns.is_bot_game do
      GameServer.send_message(socket.assigns.game_id, socket.assigns.my_name, text)
    end

    {:noreply, socket}
  end

  def handle_event("resign", _, socket) do
    GameServer.resign(socket.assigns.game_id, self())
    {:noreply, assign(socket, :show_resign_modal, false)}
  end

  def handle_event("show_resign_modal", _, socket) do
    {:noreply, assign(socket, :show_resign_modal, true)}
  end

  def handle_event("cancel_resign", _, socket) do
    {:noreply, assign(socket, :show_resign_modal, false)}
  end

  def handle_event("make_move", %{"row" => row, "col" => col}, socket) do
    GameServer.make_move(
      socket.assigns.game_id,
      self(),
      String.to_integer(row),
      String.to_integer(col)
    )

    {:noreply, socket}
  end

  def handle_event("return_to_lobby", _, socket) do
    {:noreply, push_navigate(socket, to: ~p"/?username=#{socket.assigns.my_name}")}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="mx-auto max-w-lg">
        <div class="text-center mb-6">
          <h1 class="text-3xl font-bold tracking-tight">Tris</h1>
        </div>

        <%= if @game_state do %>
          <% other_mark = if(@game_state.turn == :x, do: :o, else: :x) %>

          <div class="space-y-3 mb-6">
            <div class={[
              "px-4 py-3 rounded-box transition-all duration-300",
              @is_my_turn && "bg-primary text-primary-content",
              !@is_my_turn && "bg-base-200"
            ]}>
              <div class="flex items-center gap-2 mb-0.5">
                <span class={[
                  "size-2 rounded-full",
                  @is_my_turn && "bg-current animate-pulse",
                  !@is_my_turn && "bg-base-content/30"
                ]} />
                <span class="text-xs font-semibold uppercase tracking-wider">
                  <%= cond do %>
                    <% @is_my_turn -> %>
                      Your turn
                    <% @is_bot_game -> %>
                      Waiting for Bot...
                    <% true -> %>
                      Waiting for opponent...
                  <% end %>
                </span>
                <%= if @remaining_seconds != nil do %>
                  <span class={[
                    "ml-auto text-xs font-mono font-bold px-2 py-0.5 rounded-box transition-all duration-300",
                    @remaining_seconds <= 5 && "bg-red-500 text-white animate-pulse",
                    (@remaining_seconds > 5 and @remaining_seconds <= 10) &&
                      "bg-amber-400 text-amber-900",
                    @remaining_seconds > 10 && "bg-base-content/10"
                  ]}>
                    {@remaining_seconds}s
                  </span>
                <% end %>
              </div>
              <div class="font-bold">
                <%= if @game_state.turn == @player_mark do %>
                  You
                <% else %>
                  {@game_state.names[@game_state.turn]}
                <% end %>
                ({@game_state.turn})
              </div>
            </div>

            <div class="px-4 py-3 rounded-box bg-base-200/50 text-base-content/50">
              <div class="flex items-center gap-2 mb-0.5">
                <span class="size-2 rounded-full bg-base-content/20" />
                <span class="text-xs font-semibold uppercase tracking-wider">Waiting...</span>
              </div>
              <div class="font-bold">
                <%= if other_mark == @player_mark do %>
                  You
                <% else %>
                  {@game_state.names[other_mark]}
                <% end %>
                ({other_mark})
              </div>
            </div>
          </div>

          <div class={[
            "grid grid-cols-3 gap-2 mx-auto max-w-sm transition-all duration-300",
            !@is_my_turn && "opacity-50 pointer-events-none"
          ]}>
            <%= for row <- 0..2 do %>
              <%= for col <- 0..2 do %>
                <% cell = Map.get(@game_state.board, {row, col}) %>
                <% is_winning = Enum.member?(@game_state.winning_cells, {row, col}) %>
                <button
                  phx-click="make_move"
                  phx-value-row={row}
                  phx-value-col={col}
                  disabled={cell != nil || @game_state.status != :playing}
                  class={[
                    "aspect-square text-4xl font-bold rounded-box border-2 transition-all duration-150",
                    if(is_winning,
                      do: "bg-success text-success-content border-success",
                      else: "bg-base-200 border-base-300 hover:border-primary"
                    ),
                    if(cell == nil && @game_state.status == :playing,
                      do: "hover:bg-base-300 cursor-pointer",
                      else: "cursor-default"
                    )
                  ]}
                >
                  {cell}
                </button>
              <% end %>
            <% end %>
          </div>

          <%= if @is_human_game do %>
            <div class="mt-6 border-t border-base-300 pt-4">
              <div class="text-xs font-semibold uppercase tracking-wider text-base-content/50 mb-2">
                Chat
              </div>
              <div
                class="bg-base-200 rounded-box p-3 space-y-1 max-h-36 overflow-y-auto mb-2"
                id="chat-messages"
              >
                <%= if @chat_messages == [] do %>
                  <p class="text-xs text-base-content/40 italic">No messages yet</p>
                <% end %>
                <div :for={msg <- @chat_messages} class="text-sm">
                  <span class="font-semibold">{msg.sender}</span>
                  <span class="text-base-content/70">{msg.text}</span>
                </div>
              </div>
              <.form for={@chat_form} id="chat-form" phx-submit="send_chat" class="flex gap-2">
                <.input
                  field={@chat_form[:text]}
                  type="text"
                  placeholder="Type a message..."
                  class="input input-bordered input-sm flex-1"
                  autocomplete="off"
                />
                <button type="submit" class="btn btn-primary btn-sm">Send</button>
              </.form>
            </div>
          <% end %>

          <%= if @game_state.status == :playing do %>
            <div class="mt-6 text-center">
              <button
                phx-click="show_resign_modal"
                class="btn btn-outline btn-error btn-sm"
              >
                Resign
              </button>
            </div>
          <% end %>

          <div
            id="resign-modal"
            class={[
              "fixed inset-0 z-50 flex items-center justify-center",
              unless(@show_resign_modal, do: "hidden")
            ]}
          >
            <div class="fixed inset-0 bg-black/50" phx-click="cancel_resign" />
            <div class="relative bg-base-100 rounded-box p-6 shadow-xl max-w-sm mx-4 text-center">
              <p class="text-lg font-semibold mb-6">Are you sure you want to resign?</p>
              <div class="flex gap-3 justify-center">
                <button phx-click="cancel_resign" class="btn btn-ghost">Cancel</button>
                <button phx-click="resign" class="btn btn-error">Confirm, resign</button>
              </div>
            </div>
          </div>

          <%= if @result do %>
            <div class="text-center mt-8">
              <div class="text-2xl font-bold mb-4">{@result}</div>
              <button phx-click="return_to_lobby" class="btn btn-primary">
                Return to lobby
              </button>
              <p class="text-sm text-base-content/50 mt-3">Redirecting to lobby...</p>
            </div>
          <% end %>
        <% else %>
          <div class="text-center py-12">
            <div class="loading loading-spinner loading-lg mb-4"></div>
            <p class="text-base-content/70">Loading game...</p>
          </div>
        <% end %>
      </div>
    </Layouts.app>
    """
  end
end
