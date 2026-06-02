defmodule TrisWeb.GameLive do
  use TrisWeb, :live_view

  alias Tris.GameServer
  alias Phoenix.PubSub

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

    socket =
      socket
      |> assign(:game_id, game_id)
      |> assign(:game_state, game_state)
      |> assign(:player_mark, player_mark)
      |> assign(:is_my_turn, game_state.turn == player_mark)
      |> assign(:my_name, game_state.names[player_mark] || params["n"])
      |> assign(:opponent_name, game_state.names[opponent_mark] || params["o"])
      |> assign(:result, nil)

    {:noreply, socket}
  end

  def handle_info({:game_update, game_state}, socket) do
    result =
      cond do
        game_state.status == :won -> "#{game_state.names[game_state.winner]} wins!"
        game_state.status == :tie -> "It's a tie!"
        true -> nil
      end

    socket =
      socket
      |> assign(:game_state, game_state)
      |> assign(:is_my_turn, game_state.turn == socket.assigns.player_mark)
      |> assign(:result, result)

    {:noreply, socket}
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
    {:noreply, push_navigate(socket, to: ~p"/")}
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
                  <%= if @is_my_turn do %>
                    Your turn
                  <% else %>
                    Waiting for opponent...
                  <% end %>
                </span>
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

          <%= if @result do %>
            <div class="text-center mt-8">
              <div class="text-2xl font-bold mb-4">{@result}</div>
              <button phx-click="return_to_lobby" class="btn btn-primary">
                Return to lobby
              </button>
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
