defmodule Day08 do
  @north_delta {0, -1}
  @east_delta {1, 0}
  @south_delta {0, 1}
  @west_delta {-1, 0}

  def get_input() do
    File.read!("data/08.txt")
    |> String.split("\n")
    |> Enum.filter(&(&1 != ""))
    |> Enum.map(fn line -> line |> String.to_charlist() |> Enum.map(&(&1 - ?0)) end)
    |> to_grid()
  end

  defp to_grid(list) do
    rows = Enum.zip(1..length(list), list)

    grid =
      for {y, row} <- rows, reduce: %{} do
        acc ->
          cols = Enum.zip(1..length(row), row)

          Map.merge(
            acc,
            for {x, col} <- cols, into: %{} do
              {{x, y}, col}
            end
          )
      end

    {grid, length(list)}
  end

  def is_visible(query_pos = {pos_x, pos_y}, {grid, grid_size}) do
    north_scan = scan_visible({pos_x, grid_size}, query_pos, @north_delta, grid)
    east_scan = scan_visible({1, pos_y}, query_pos, @east_delta, grid)
    south_scan = scan_visible({pos_x, 1}, query_pos, @south_delta, grid)
    west_scan = scan_visible({grid_size, pos_y}, query_pos, @west_delta, grid)

    north_scan || east_scan || south_scan || west_scan
  end

  defp scan_visible(query_pos, query_pos, _delta, _grid), do: true

  defp scan_visible(current_pos, query_pos, delta, grid) do
    if current_pos == query_pos do
      IO.puts("how did I get here")
    end

    current_height = grid[current_pos]
    query_height = grid[query_pos]
    next_pos = add_delta(current_pos, delta)

    case current_height < query_height do
      true -> scan_visible(next_pos, query_pos, delta, grid)
      false -> false
    end
  end

  def scenic_score(query_pos, {grid, grid_size}) do
    starting_height = grid[query_pos]

    north_score = scan_scenic(query_pos, grid_size, @north_delta, grid, starting_height, 0)
    east_score = scan_scenic(query_pos, grid_size, @east_delta, grid, starting_height, 0)
    south_score = scan_scenic(query_pos, grid_size, @south_delta, grid, starting_height, 0)
    west_score = scan_scenic(query_pos, grid_size, @west_delta, grid, starting_height, 0)

    north_score * east_score * south_score * west_score
  end

  defp scan_scenic({current_x, current_y}, grid_size, _delta, _grid, _starting_height, score)
       when current_x <= 1 or current_x >= grid_size or current_y <= 1 or current_y >= grid_size,
       do: score

  defp scan_scenic(current_pos, grid_size, delta, grid, starting_height, score) do
    new_score = score + 1
    next_pos = add_delta(current_pos, delta)
    next_height = grid[next_pos]

    case next_height < starting_height do
      true -> scan_scenic(next_pos, grid_size, delta, grid, starting_height, new_score)
      false -> new_score
    end
  end

  defp add_delta({pos_x, pos_y}, {dx, dy}), do: {pos_x + dx, pos_y + dy}
end

input = {grid, _grid_size} = Day08.get_input()
visible_trees = grid |> Map.keys() |> Enum.filter(&Day08.is_visible(&1, input))
scenic_scores = grid |> Map.keys() |> Enum.map(&Day08.scenic_score(&1, input))

IO.puts("Part 1: #{length(visible_trees)}")
IO.puts("Part 2: #{scenic_scores |> Enum.max()}")
