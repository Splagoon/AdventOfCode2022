defmodule Day10 do
  def get_input() do
    File.read!("data/10.txt")
    |> String.split("\n")
    |> Enum.filter(&(&1 != ""))
    |> Enum.map(&String.split/1)
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(["noop"]), do: {:noop}
  defp parse_line(["addx", x]), do: {:addx, String.to_integer(x)}

  def execute(instructions) do
    {cycles, _x} = Enum.reduce(instructions, {[], 1}, &execute_one/2)
    cycles = Enum.reverse(cycles)
    Enum.zip(1..length(cycles), cycles) |> Map.new()
  end

  defp execute_one({:noop}, {cycles, x}), do: {[x | cycles], x}
  defp execute_one({:addx, dx}, {cycles, x}), do: {[x, x | cycles], x + dx}

  def signal_strengths(cycles, indexes) do
    for index <- indexes do
      index * cycles[index]
    end
  end

  @pixels_per_scanline 40
  @scanlines 6
  def render(cycles) do
    chars =
      for i <- 0..(@pixels_per_scanline * @scanlines - 1) do
        x = cycles[i + 1]
        IO.puts("i: #{i}; x: #{x}")
        if rem(i, @pixels_per_scanline) in (x - 1)..(x + 1), do: ?#, else: ?.
      end

    chars
    |> Enum.chunk_every(@pixels_per_scanline)
    |> Enum.map(&to_string/1)
    |> Enum.join("\n")
  end
end

cycles = Day10.get_input() |> Day10.execute()

IO.puts("Part 1: #{Day10.signal_strengths(cycles, [20, 60, 100, 140, 180, 220]) |> Enum.sum()}")
IO.puts("Part 2:\n#{Day10.render(cycles)}")
