defmodule Day09 do
  def get_input() do
    File.read!("data/09.txt")
    |> String.split("\n")
    |> Enum.filter(&(&1 != ""))
    |> Enum.map(&String.split/1)
    |> Enum.flat_map(&parse_line/1)
  end

  @direction_map %{"U" => :u, "D" => :d, "L" => :l, "R" => :r}
  defp parse_line([dir, n]) do
    List.duplicate(@direction_map[dir], String.to_integer(n))
  end

  def execute(directions, num_knots) do
    {knots, tail_visited} =
      for direction <- directions, reduce: {List.duplicate({0, 0}, num_knots), MapSet.new()} do
        {[head | knots], tail_visited} ->
          new_head = move_head(head, direction)
          {new_knots, tail_pos} = move_knots(new_head, knots, [])
          {[new_head | new_knots], MapSet.put(tail_visited, tail_pos)}
      end

    MapSet.size(tail_visited)
  end

  defp move_head({hx, hy}, direction) do
    case direction do
      :u -> {hx, hy - 1}
      :d -> {hx, hy + 1}
      :l -> {hx - 1, hy}
      :r -> {hx + 1, hy}
    end
  end

  defp move_knots(tail_pos, [], result) do
    {Enum.reverse(result), tail_pos}
  end

  defp move_knots(prev_knot_pos, [knot_pos | remaining_knots], result) do
    new_knot_pos = move_knot(prev_knot_pos, knot_pos)
    move_knots(new_knot_pos, remaining_knots, [new_knot_pos | result])
  end

  defp move_knot(prev_knot_pos = {pkx, pky}, knot_pos = {kx, ky}) do
    if distance(prev_knot_pos, knot_pos) <= 1 do
      knot_pos
    else
      {next_coord(kx, pkx), next_coord(ky, pky)}
    end
  end

  def distance({x1, y1}, {x2, y2}) do
    max(abs(x1 - x2), abs(y1 - y2))
  end

  defp next_coord(x1, x2) do
    cond do
      x1 < x2 -> x1 + 1
      x1 > x2 -> x1 - 1
      true -> x1
    end
  end
end

input = Day09.get_input()

IO.puts("Part 1: #{input |> Day09.execute(2)}")
IO.puts("Part 2: #{input |> Day09.execute(10)}")
