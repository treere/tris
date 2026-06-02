defmodule Tris.GameServerTest do
  use ExUnit.Case, async: true

  alias Tris.GameServer

  setup do
    game_id = "test-#{System.unique_integer([:positive])}"

    {:ok, _pid} =
      start_supervised(
        {Tris.GameServer,
         %{
           game_id: game_id,
           player1_pid: self(),
           player1_name: "Player1",
           player2_pid: :player2_pid,
           player2_name: "Player2"
         }}
      )

    %{game_id: game_id}
  end

  describe "bot game integration" do
    setup do
      bot_game_id = "bot-test-#{System.unique_integer([:positive])}"

      start_supervised(
        {Tris.GameServer,
         %{
           game_id: bot_game_id,
           player1_pid: self(),
           player1_name: "Human",
           player2_pid: :bot,
           player2_name: "Bot (Hard)",
           bot_difficulty: :hard
         }},
        id: :bot_game
      )

      %{game_id: bot_game_id}
    end

    test "human can make first move in bot game", %{game_id: game_id} do
      assert {:ok, state} = GameServer.make_move(game_id, self(), 0, 0)
      assert state.board[{0, 0}] == :x
      assert state.turn == :o
    end

    test "rejects human move on occupied cell in bot game", %{game_id: game_id} do
      GameServer.make_move(game_id, self(), 0, 0)
      assert {:error, :cell_occupied} = GameServer.make_move(game_id, self(), 0, 0)
    end

    test "bot game state has bot_difficulty set", %{game_id: game_id} do
      state = GameServer.get_state(game_id)
      assert state.bot_difficulty == :hard
      assert state.players[:o] == :bot
    end
  end

  describe "make_move/4" do
    test "allows X to make the first move", %{game_id: game_id} do
      assert {:ok, state} = Tris.GameServer.make_move(game_id, self(), 0, 0)
      assert state.board[{0, 0}] == :x
      assert state.turn == :o
    end

    test "rejects move on occupied cell", %{game_id: game_id} do
      Tris.GameServer.make_move(game_id, self(), 0, 0)
      assert {:error, :cell_occupied} = Tris.GameServer.make_move(game_id, :player2_pid, 0, 0)
    end

    test "rejects move when not your turn", %{game_id: game_id} do
      assert {:error, :not_your_turn} = Tris.GameServer.make_move(game_id, :player2_pid, 0, 0)
    end

    test "detects win on row", %{game_id: game_id} do
      Tris.GameServer.make_move(game_id, self(), 0, 0)
      Tris.GameServer.make_move(game_id, :player2_pid, 1, 0)
      Tris.GameServer.make_move(game_id, self(), 0, 1)
      Tris.GameServer.make_move(game_id, :player2_pid, 1, 1)
      {:ok, state} = Tris.GameServer.make_move(game_id, self(), 0, 2)

      assert state.status == :won
      assert state.winner == :x
    end

    test "detects tie", %{game_id: game_id} do
      {:ok, _} = Tris.GameServer.make_move(game_id, self(), 0, 0)
      {:ok, _} = Tris.GameServer.make_move(game_id, :player2_pid, 0, 1)
      {:ok, _} = Tris.GameServer.make_move(game_id, self(), 0, 2)
      {:ok, _} = Tris.GameServer.make_move(game_id, :player2_pid, 1, 2)
      {:ok, _} = Tris.GameServer.make_move(game_id, self(), 1, 0)
      {:ok, _} = Tris.GameServer.make_move(game_id, :player2_pid, 2, 0)
      {:ok, _} = Tris.GameServer.make_move(game_id, self(), 1, 1)
      {:ok, _} = Tris.GameServer.make_move(game_id, :player2_pid, 2, 2)
      {:ok, state} = Tris.GameServer.make_move(game_id, self(), 2, 1)

      assert state.status == :tie
      assert state.winner == nil
    end
  end
end
