defmodule Tris.Matchmaker do
  use GenServer

  alias Tris.GameSupervisor

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def ask_to_play(player_pid, player_name) do
    GenServer.call(__MODULE__, {:ask_to_play, player_pid, player_name}, :infinity)
  end

  def cancel(player_pid) do
    GenServer.call(__MODULE__, {:cancel, player_pid})
  end

  @impl true
  def init(_opts) do
    {:ok, %{queue: []}}
  end

  @impl true
  def handle_call({:ask_to_play, player_pid, player_name}, _from, state) do
    case state.queue do
      [{first_pid, first_name} | rest] ->
        game_id = start_game(first_pid, first_name, player_pid, player_name)
        new_state = %{state | queue: rest}
        {:reply, {:matched, game_id, :o, player_name, first_name}, new_state}

      [] ->
        new_state = %{state | queue: [{player_pid, player_name}]}
        send(player_pid, :waiting)
        {:reply, :waiting, new_state}
    end
  end

  def handle_call({:cancel, player_pid}, _from, state) do
    new_queue = Enum.reject(state.queue, fn {pid, _name} -> pid == player_pid end)
    {:reply, :ok, %{state | queue: new_queue}}
  end

  defp start_game(player1_pid, player1_name, player2_pid, player2_name) do
    game_id = "#{System.unique_integer([:positive])}"

    {:ok, _pid} =
      GameSupervisor.start_game(
        game_id,
        player1_pid,
        player1_name,
        player2_pid,
        player2_name
      )

    send(player1_pid, {:matched, game_id, :x, player1_name, player2_name})
    send(player2_pid, {:matched, game_id, :o, player2_name, player1_name})
    game_id
  end
end
