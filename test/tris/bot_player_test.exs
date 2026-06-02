defmodule Tris.BotPlayerTest do
  use ExUnit.Case, async: true

  alias Tris.BotPlayer

  describe "move/2 with :easy difficulty" do
    test "returns a valid empty cell on empty board" do
      {row, col} = BotPlayer.move(%{}, :easy)
      assert row in 0..2
      assert col in 0..2
    end

    test "returns a valid empty cell on partially filled board" do
      board = %{{0, 0} => :x, {0, 1} => :o}
      {row, col} = BotPlayer.move(board, :easy)
      assert not Map.has_key?(board, {row, col})
      assert row in 0..2
      assert col in 0..2
    end

    test "returns the only remaining cell" do
      board =
        for row <- 0..2, col <- 0..2, {row, col} != {1, 1}, into: %{} do
          {{row, col}, :x}
        end

      assert BotPlayer.move(board, :easy) == {1, 1}
    end
  end

  describe "move/2 with :hard difficulty" do
    test "returns a valid move on empty board" do
      {row, col} = BotPlayer.move(%{}, :hard)
      assert row in 0..2
      assert col in 0..2
    end

    test "takes winning move when available" do
      board = %{{0, 0} => :o, {0, 1} => :o}
      assert BotPlayer.move(board, :hard) == {0, 2}
    end

    test "blocks opponent's winning move" do
      board = %{{0, 0} => :x, {0, 1} => :x}
      assert BotPlayer.move(board, :hard) == {0, 2}
    end

    test "takes center on first move as :o" do
      board = %{{0, 0} => :x}
      assert BotPlayer.move(board, :hard) == {1, 1}
    end
  end
end
