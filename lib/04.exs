defmodule Day04 do
  @line_regex ~r/^(\d+)\-(\d+),(\d+)\-(\d+)$/

  def get_input() do
    File.read!("data/04.txt")
    |> String.split("\n")
    |> Enum.filter(&(&1 != ""))
    |> Enum.map(fn line ->
      [_ | captures] = Regex.run(@line_regex, line)
      [lo1, hi1, lo2, hi2] = captures |> Enum.map(&String.to_integer/1)
      {lo1..hi1, lo2..hi2}
    end)
  end

  def either_range_contains_other({range1, range2}),
    do: range_contains(range1, range2) or range_contains(range2, range1)

  defp range_contains(lo1..hi1, lo2..hi2), do: lo1 <= lo2 and hi1 >= hi2

  def ranges_overlap({range1, range2}), do: not Range.disjoint?(range1, range2)
end

input = Day04.get_input()

IO.puts("Part 1: #{input |> Enum.filter(&Day04.either_range_contains_other/1) |> Enum.count()}")
IO.puts("Part 2: #{input |> Enum.filter(&Day04.ranges_overlap/1) |> Enum.count()}")
