defmodule Day14 do
  @sand_spawn {500, 0}

  def get_input() do
    File.read!("data/14.txt")
    |> String.split("\n")
    |> Enum.filter(&(&1 != ""))
    |> Enum.map(&parse_line/1)
    |> Enum.reduce(%{}, &draw_lines/2)
  end

  defp parse_line(line) do
    line
    |> String.split(" -> ")
    |> Enum.map(fn coord ->
      coord
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
    end)
  end

  defp draw_lines([{x1, y1} | next_points = [{x2, y2} | _]], grid) do
    new_grid =
      for x <- x1..x2, reduce: grid do
        grid ->
          for y <- y1..y2, reduce: grid do
            grid ->
              Map.put(grid, {x, y}, :rock)
          end
      end

    draw_lines(next_points, new_grid)
  end

  defp draw_lines(_, grid), do: grid

  defp lookup(grid, coord, floor_plane) do
    case coord do
      {_, ^floor_plane} -> :rock
      _ -> Map.get(grid, coord, :air)
    end
  end

  def simulate_sand(grid, abyss_plane, stop_at_abyss?) do
    floor_plane = abyss_plane + 2

    case simulate_step(grid, @sand_spawn, {abyss_plane, floor_plane, stop_at_abyss?}) do
      {:abyss, grid} ->
        grid

      {:settled, grid} ->
        if Map.has_key?(grid, @sand_spawn),
          do: grid,
          else: simulate_sand(grid, abyss_plane, stop_at_abyss?)
    end
  end

  defp simulate_step(grid, sand_pos, floor = {abyss_plane, floor_plane, stop_at_abyss?}) do
    down = add(sand_pos, {0, 1})
    down_left = add(sand_pos, {-1, 1})
    down_right = add(sand_pos, {1, 1})

    cond do
      stop_at_abyss? and elem(down, 1) > abyss_plane ->
        {:abyss, grid}

      lookup(grid, down, floor_plane) == :air ->
        simulate_step(grid, down, floor)

      lookup(grid, down_left, floor_plane) == :air ->
        simulate_step(grid, down_left, floor)

      lookup(grid, down_right, floor_plane) == :air ->
        simulate_step(grid, down_right, floor)

      true ->
        {:settled, Map.put(grid, sand_pos, :sand)}
    end
  end

  defp add({x, y}, {dx, dy}), do: {x + dx, y + dy}
end

starting_grid = Day14.get_input()

abyss_plane =
  starting_grid
  |> Map.keys()
  |> Enum.map(&elem(&1, 1))
  |> Enum.max()

IO.puts(
  "Part 1: #{Day14.simulate_sand(starting_grid, abyss_plane, true) |> Map.values() |> Enum.count(&(&1 == :sand))}"
)

IO.puts(
  "Part 2: #{Day14.simulate_sand(starting_grid, abyss_plane, false) |> Map.values() |> Enum.count(&(&1 == :sand))}"
)
