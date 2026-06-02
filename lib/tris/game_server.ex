defmodule Tris.GameServer do
  use GenServer

  alias Phoenix.PubSub
  alias Tris.BotPlayer

  @bot_move_delay 800
  @turn_timeout 30_000

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: via_tuple(args.game_id))
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker
    }
  end

  def make_move(game_id, player_pid, row, col) do
    GenServer.call(via_tuple(game_id), {:make_move, player_pid, row, col})
  end

  def get_state(game_id) do
    GenServer.call(via_tuple(game_id), :get_state)
  end

  def register_player(game_id, mark, pid) do
    GenServer.call(via_tuple(game_id), {:register_player, mark, pid})
  end

  defp via_tuple(game_id) do
    {:via, Registry, {Tris.GameRegistry, game_id}}
  end

  @impl true
  def init(args) do
    state = %{
      game_id: args.game_id,
      board: %{},
      players: %{x: args.player1_pid, o: args.player2_pid},
      names: %{x: args.player1_name, o: args.player2_name},
      turn: :x,
      status: :playing,
      winner: nil,
      winning_cells: [],
      bot_difficulty: Map.get(args, :bot_difficulty),
      timer_ref: nil,
      turn_started_at: nil,
      timeout_player: nil
    }

    state = start_timer(state)
    {:ok, state}
  end

  @impl true
  def handle_call({:make_move, player_pid, row, col}, _from, state) do
    cond do
      state.status != :playing ->
        {:reply, {:error, :game_over}, state}

      state.players[state.turn] != player_pid and not is_bot_turn?(state) ->
        {:reply, {:error, :not_your_turn}, state}

      Map.has_key?(state.board, {row, col}) ->
        {:reply, {:error, :cell_occupied}, state}

      true ->
        new_state = apply_move(state, row, col)
        new_state = schedule_bot_move(new_state)
        {:reply, {:ok, new_state}, new_state}
    end
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:register_player, mark, pid}, _from, state) do
    {:reply, :ok, put_in(state, [:players, mark], pid)}
  end

  @impl true
  def handle_info({:bot_move, bot_mark}, state) do
    {row, col} = BotPlayer.move(state.board, state.bot_difficulty)
    new_state = apply_move(state, row, col, bot_mark)
    {:noreply, new_state}
  end

  @impl true
  def handle_info({:turn_timeout, player}, state) do
    if state.status == :playing and state.turn == player do
      opponent = if player == :x, do: :o, else: :x

      new_state = %{
        state
        | status: :won,
          winner: opponent,
          timeout_player: player,
          timer_ref: nil,
          turn_started_at: nil
      }

      broadcast_update(new_state)
      {:noreply, new_state}
    else
      {:noreply, state}
    end
  end

  defp is_bot_turn?(state) do
    state.bot_difficulty != nil and state.players[state.turn] == :bot
  end

  defp schedule_bot_move(state) do
    if state.status == :playing and state.players[state.turn] == :bot do
      Process.send_after(self(), {:bot_move, state.turn}, @bot_move_delay)
    end

    state
  end

  defp start_timer(state) do
    if state.status == :playing and not is_bot_turn?(state) do
      timer_ref = Process.send_after(self(), {:turn_timeout, state.turn}, @turn_timeout)
      %{state | timer_ref: timer_ref, turn_started_at: System.monotonic_time()}
    else
      %{state | timer_ref: nil, turn_started_at: nil}
    end
  end

  defp cancel_timer(state) do
    if state.timer_ref do
      Process.cancel_timer(state.timer_ref)
    end

    %{state | timer_ref: nil}
  end

  defp apply_move(state, row, col, player \\ nil) do
    state = cancel_timer(state)
    player = player || state.turn
    new_board = Map.put(state.board, {row, col}, player)
    next_turn = if player == :x, do: :o, else: :x

    {won, winning_cells} = check_win(new_board, player)
    tie = not won and map_size(new_board) == 9

    status = if(won, do: :won, else: if(tie, do: :tie, else: :playing))

    new_state = %{
      state
      | board: new_board,
        turn: next_turn,
        status: status,
        winner: if(won, do: player, else: nil),
        winning_cells: winning_cells,
        timeout_player: nil
    }

    new_state =
      if new_state.status == :playing do
        start_timer(new_state)
      else
        new_state
      end

    broadcast_update(new_state)
    new_state
  end

  defp broadcast_update(state) do
    PubSub.broadcast(Tris.PubSub, "game:#{state.game_id}", {:game_update, state})
  end

  defp check_win(board, player) do
    win_patterns = [
      [{0, 0}, {0, 1}, {0, 2}],
      [{1, 0}, {1, 1}, {1, 2}],
      [{2, 0}, {2, 1}, {2, 2}],
      [{0, 0}, {1, 0}, {2, 0}],
      [{0, 1}, {1, 1}, {2, 1}],
      [{0, 2}, {1, 2}, {2, 2}],
      [{0, 0}, {1, 1}, {2, 2}],
      [{0, 2}, {1, 1}, {2, 0}]
    ]

    Enum.reduce_while(win_patterns, {false, []}, fn cells, _acc ->
      if Enum.all?(cells, &(Map.get(board, &1) == player)) do
        {:halt, {true, cells}}
      else
        {:cont, {false, []}}
      end
    end)
  end
end
