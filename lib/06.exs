defmodule Day06 do
  def get_input() do
    File.read!("data/06.txt")
    |> String.to_charlist()
  end

  def find_marker(input, marker_size) do
    scan(0, input, marker_size)
  end

  defp scan(pos, input, marker_size) do
    num_different = input |> Enum.take(marker_size) |> Enum.uniq() |> length()

    case num_different do
      ^marker_size ->
        pos + marker_size

      _ ->
        [_ | tail] = input
        scan(pos + 1, tail, marker_size)
    end
  end
end

input = Day06.get_input()

IO.puts("Part 1: #{Day06.find_marker(input, 4)}")
IO.puts("Part 2: #{Day06.find_marker(input, 14)}")
