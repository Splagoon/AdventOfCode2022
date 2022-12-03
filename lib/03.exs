defmodule Day03 do
  def get_input() do
    File.read!("data/03.txt")
    |> String.split("\n")
    |> Enum.filter(&(&1 != ""))
    |> Enum.map(fn inventory ->
      inventory
      |> String.to_charlist()
      |> Enum.split(div(String.length(inventory), 2))
    end)
  end

  defp priority(c) when c <= ?Z, do: c - ?A + 27
  defp priority(c), do: c - ?a + 1

  # Part 1 version
  def common_item({a, b}) do
    a_set = MapSet.new(a)
    b_set = MapSet.new(b)

    MapSet.intersection(a_set, b_set)
    |> MapSet.to_list()
    |> List.first()
  end

  # Part 2 version
  def common_item([{a, b}, {c, d}, {e, f}]) do
    set_1 = MapSet.new(a ++ b)
    set_2 = MapSet.new(c ++ d)
    set_3 = MapSet.new(e ++ f)

    MapSet.intersection(set_1, set_2)
    |> MapSet.intersection(set_3)
    |> MapSet.to_list()
    |> List.first()
  end

  def common_item_priority(input) do
    input
    |> common_item()
    |> priority()
  end
end

input = Day03.get_input()

IO.puts("Part 1: #{input |> Enum.map(&Day03.common_item_priority/1) |> Enum.sum()}")

IO.puts(
  "Part 2: #{input |> Enum.chunk_every(3) |> Enum.map(&Day03.common_item_priority/1) |> Enum.sum()}"
)
