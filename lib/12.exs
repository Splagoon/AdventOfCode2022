defmodule Day12 do
  @min_height 0
  @max_height 25

  def get_input() do
    positions =
      File.read!("data/12.txt")
      |> String.split("\n")
      |> Enum.filter(&(&1 != ""))
      |> Enum.with_index(fn row, y ->
        indexed_chars =
          row
          |> String.to_charlist()
          |> Enum.with_index()

        for {c, x} <- indexed_chars, do: {{x, y}, c}
      end)
      |> Enum.flat_map(& &1)

    for {pos, c} <- positions, reduce: %{grid: %{}, start: nil, end: nil} do
      acc = %{grid: grid} ->
        grid = Map.put(grid, pos, height(c))

        case c do
          ?S -> %{acc | grid: grid, start: pos}
          ?E -> %{acc | grid: grid, end: pos}
          _ -> %{acc | grid: grid}
        end
    end
  end

  defp height(?S), do: @min_height
  defp height(?E), do: @max_height
  defp height(c), do: c - ?a

  def shortest_path(grid, start_pos, end_pos) do
    path_loop(grid, end_pos, :queue.from_list([[start_pos]]), MapSet.new([start_pos]))
  end

  defp path_loop(
         grid,
         end_pos,
         next_paths,
         visited_set
       ) do
    case :queue.out(next_paths) do
      {:empty, _} ->
        :impossible

      {{:value, current_path}, remaining_paths} ->
        case current_path do
          [^end_pos | _] ->
            current_path

          [current_pos | _] ->
            visited_set = MapSet.put(visited_set, current_pos)

            neighbors = neighbors(grid, current_pos, visited_set)
            visited_set = neighbors |> Enum.reduce(visited_set, &MapSet.put(&2, &1))

            next_paths =
              neighbors
              |> Enum.map(&[&1 | current_path])
              |> Enum.reduce(remaining_paths, &:queue.in/2)

            path_loop(grid, end_pos, next_paths, visited_set)
        end
    end
  end

  defp neighbors(grid, pos, visited_set) do
    next_height = grid[pos] + 1

    [{1, 0}, {-1, 0}, {0, 1}, {0, -1}]
    |> Enum.map(&add(pos, &1))
    |> Enum.filter(&(Map.get(grid, &1, 1_000) <= next_height))
    |> Enum.filter(&(not MapSet.member?(visited_set, &1)))
  end

  defp add({x, y}, {dx, dy}), do: {x + dx, y + dy}
end

%{grid: grid, start: path_start, end: path_end} = Day12.get_input()
shortest_path = Day12.shortest_path(grid, path_start, path_end)

IO.puts("Part 1: #{length(shortest_path) - 1}")

lowest_elevations = grid |> Map.filter(fn {_key, value} -> value == 0 end) |> Map.keys()

shortest_path =
  lowest_elevations
  |> Enum.map(&Day12.shortest_path(grid, &1, path_end))
  |> Enum.filter(&(&1 != :impossible))
  |> Enum.min_by(&length/1)

IO.puts("Part 2: #{length(shortest_path) - 1}")
