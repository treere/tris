defmodule Tris.BotPlayer do
  @moduledoc false

  def move(board, :easy) do
    board
    |> empty_cells()
    |> Enum.random()
  end

  def move(board, :hard) do
    {_score, best_move} = minimax(board, :o)
    best_move
  end

  defp empty_cells(board) do
    for row <- 0..2, col <- 0..2, not Map.has_key?(board, {row, col}), do: {row, col}
  end

  defp winner(board) do
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

    result =
      Enum.find_value(win_patterns, fn cells ->
        cond do
          Enum.all?(cells, &(Map.get(board, &1) == :x)) -> :x
          Enum.all?(cells, &(Map.get(board, &1) == :o)) -> :o
          true -> nil
        end
      end)

    result || if(map_size(board) == 9, do: :tie)
  end

  defp minimax(board, current_player) do
    case winner(board) do
      :x ->
        {-1, nil}

      :o ->
        {1, nil}

      :tie ->
        {0, nil}

      nil ->
        empty_cells(board)
        |> Enum.map(fn cell ->
          new_board = Map.put(board, cell, current_player)
          next_player = if current_player == :x, do: :o, else: :x
          {score, _} = minimax(new_board, next_player)
          {score, cell}
        end)
        |> case do
          [] ->
            {0, nil}

          scored_moves ->
            if current_player == :o do
              Enum.max_by(scored_moves, fn {score, _} -> score end)
            else
              Enum.min_by(scored_moves, fn {score, _} -> score end)
            end
        end
    end
  end
end
