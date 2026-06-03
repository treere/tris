defmodule TrisWeb.AdminLive do
  use TrisWeb, :live_view

  alias Tris.GameServer

  def mount(_params, _session, socket) do
    socket = assign(socket, :stats, collect_stats())

    Process.send_after(self(), :tick, 3000)

    {:ok, socket}
  end

  def handle_info(:tick, socket) do
    Process.send_after(self(), :tick, 3000)

    {:noreply, assign(socket, :stats, collect_stats())}
  end

  defp collect_stats do
    game_ids = Registry.select(Tris.GameRegistry, [{{:"$1", :_, :_}, [], [:"$1"]}])

    games =
      game_ids
      |> Task.async_stream(&safe_get_state/1,
        timeout: 5000,
        max_concurrency: 20,
        ordered: false
      )
      |> Enum.reduce([], fn
        {:ok, state}, acc when is_map(state) -> [state | acc]
        _result, acc -> acc
      end)

    all_presences = Tris.Presence.list("user")

    lobby_users =
      Enum.count(all_presences, fn {_key, data} ->
        data.metas |> List.first() |> Map.get(:location) == "lobby"
      end)

    in_game_names =
      games
      |> Enum.flat_map(&Map.values(&1.names))
      |> Enum.reject(&String.contains?(&1, "Bot"))
      |> Enum.uniq()

    queue_state = :sys.get_state(Tris.Matchmaker)
    queue_depth = length(queue_state.queue)

    waiting_names = Enum.map(queue_state.queue, fn {_pid, name} -> name end)

    %{
      lobby_users: lobby_users,
      in_game_users: length(in_game_names),
      waiting_users: queue_depth,
      total_users: lobby_users + length(in_game_names) + queue_depth,
      active_games_count: length(games),
      bot_games_count: Enum.count(games, &(&1.bot_difficulty != nil)),
      human_games_count: Enum.count(games, &(&1.bot_difficulty == nil)),
      easy_bot: Enum.count(games, &(&1.bot_difficulty == :easy)),
      hard_bot: Enum.count(games, &(&1.bot_difficulty == :hard)),
      queue_depth: queue_depth,
      waiting_names: waiting_names,
      games: Enum.sort_by(games, & &1.game_id)
    }
  end

  defp safe_get_state(game_id) do
    case Registry.lookup(Tris.GameRegistry, game_id) do
      [{_pid, _}] -> GameServer.get_state(game_id)
      [] -> nil
    end
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="mx-auto max-w-3xl">
        <div class="text-center mb-8">
          <h1 class="text-4xl font-bold tracking-tight">Admin Dashboard</h1>
          <p class="mt-2 text-base-content/60">Real-time usage analytics</p>
        </div>

        <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
          <div class="stat-card bg-primary text-primary-content rounded-box p-4 text-center">
            <div class="text-3xl font-bold">{@stats.total_users}</div>
            <div class="text-xs uppercase tracking-wider opacity-80">Users Online</div>
          </div>
          <div class="stat-card bg-secondary text-secondary-content rounded-box p-4 text-center">
            <div class="text-3xl font-bold">{@stats.active_games_count}</div>
            <div class="text-xs uppercase tracking-wider opacity-80">Active Games</div>
          </div>
          <div class="stat-card bg-accent text-accent-content rounded-box p-4 text-center">
            <div class="text-3xl font-bold">{@stats.lobby_users}</div>
            <div class="text-xs uppercase tracking-wider opacity-80">In Lobby</div>
          </div>
          <div class="stat-card bg-neutral text-neutral-content rounded-box p-4 text-center">
            <div class="text-3xl font-bold">{@stats.queue_depth}</div>
            <div class="text-xs uppercase tracking-wider opacity-80">In Queue</div>
          </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
          <div class="card bg-base-200 p-5 rounded-box">
            <h2 class="text-sm font-semibold uppercase tracking-wider mb-3 text-base-content/70">
              Game Types
            </h2>
            <div class="space-y-2">
              <div class="flex justify-between">
                <span>Human vs Human</span>
                <span class="font-bold">{@stats.human_games_count}</span>
              </div>
              <div class="flex justify-between">
                <span>Bot Games</span>
                <span class="font-bold">{@stats.bot_games_count}</span>
              </div>
              <div class="divider my-2" />
              <div class="flex justify-between text-base-content/60">
                <span class="pl-4">— Easy Bot</span>
                <span>{@stats.easy_bot}</span>
              </div>
              <div class="flex justify-between text-base-content/60">
                <span class="pl-4">— Hard Bot</span>
                <span>{@stats.hard_bot}</span>
              </div>
            </div>
          </div>

          <div class="card bg-base-200 p-5 rounded-box">
            <h2 class="text-sm font-semibold uppercase tracking-wider mb-3 text-base-content/70">
              Players
            </h2>
            <div class="space-y-2">
              <div class="flex justify-between">
                <span>In Lobby</span>
                <span class="font-bold">{@stats.lobby_users}</span>
              </div>
              <div class="flex justify-between">
                <span>In Games</span>
                <span class="font-bold">{@stats.in_game_users}</span>
              </div>
              <div class="flex justify-between">
                <span>Waiting in Queue</span>
                <span class="font-bold">{@stats.waiting_users}</span>
              </div>
              <div class="divider my-2" />
              <div class="flex justify-between font-bold">
                <span>Total</span>
                <span>{@stats.total_users}</span>
              </div>
            </div>
          </div>
        </div>

        <div class="card bg-base-200 p-5 rounded-box">
          <h2 class="text-sm font-semibold uppercase tracking-wider mb-3 text-base-content/70">
            Active Games ({@stats.active_games_count})
          </h2>
          <%= if @stats.games == [] do %>
            <p class="text-base-content/40 text-sm italic py-4 text-center">No active games</p>
          <% else %>
            <div class="overflow-x-auto">
              <table class="table table-sm">
                <thead>
                  <tr class="text-xs uppercase tracking-wider text-base-content/50">
                    <th>Game</th>
                    <th>Players</th>
                    <th>Type</th>
                    <th>Turn</th>
                    <th>Status</th>
                  </tr>
                </thead>
                <tbody>
                  <tr :for={game <- @stats.games}>
                    <td class="font-mono text-xs">{game.game_id}</td>
                    <td>
                      <%= for {mark, name} <- game.names do %>
                        <span class={if(mark == :x, do: "text-info", else: "text-secondary")}>
                          {name}
                        </span>
                        <%= if mark == :x do %>
                          vs
                        <% end %>
                      <% end %>
                    </td>
                    <td>
                      <%= if game.bot_difficulty do %>
                        <span class="badge badge-sm">
                          Bot ({game.bot_difficulty})
                        </span>
                      <% else %>
                        <span class="badge badge-sm badge-outline">Human</span>
                      <% end %>
                    </td>
                    <td class="font-mono text-xs">{game.turn}</td>
                    <td>
                      <span class={[
                        "badge badge-sm",
                        game.status == :playing && "badge-success",
                        game.status == :won && "badge-warning",
                        game.status == :tie && "badge-ghost"
                      ]}>
                        {game.status}
                      </span>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          <% end %>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
