inventories =
  File.read!("data/01.txt")
  |> String.split("\n\n")
  |> Enum.map(fn x ->
    x
    |> String.split("\n")
    |> Enum.filter(&(&1 != ""))
    |> Enum.map(&String.to_integer/1)
    |> Enum.sum()
  end)
  |> Enum.sort(:desc)

IO.puts("Part 1: #{List.first(inventories)}")
IO.puts("Part 2: #{inventories |> Enum.take(3) |> Enum.sum()}")
