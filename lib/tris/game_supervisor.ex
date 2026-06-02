defmodule Tris.GameSupervisor do
  use DynamicSupervisor

  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def start_game(game_id, player1_pid, player1_name, player2_pid, player2_name) do
    args = %{
      game_id: game_id,
      player1_pid: player1_pid,
      player1_name: player1_name,
      player2_pid: player2_pid,
      player2_name: player2_name
    }

    DynamicSupervisor.start_child(__MODULE__, {Tris.GameServer, args})
  end

  @impl true
  def init(_opts) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
