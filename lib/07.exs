defmodule Day07 do
  @disk_size 70_000_000
  @update_size 30_000_000

  def get_input() do
    File.read!("data/07.txt")
    |> String.split("\n")
    |> Enum.filter(&(&1 != ""))
    |> Enum.map(&String.split/1)
    |> Enum.map(&parse_line/1)
    |> Enum.reduce({[], %{}}, &read_line/2)
    |> elem(1)
    |> get_dir_sizes()
  end

  defp parse_line(["$", "cd", dir]), do: {:cmd, :cd, dir}
  defp parse_line(["$", "ls"]), do: {:cmd, :ls}
  defp parse_line(["dir", dir_name]), do: {:dir, dir_name}
  defp parse_line([file_size, file_name]), do: {:file, file_name, String.to_integer(file_size)}

  defp read_line({_, tree}, []), do: tree

  defp read_line({:cmd, :cd, dir}, {cwd, tree}) do
    new_cwd =
      case dir do
        "/" ->
          []

        ".." ->
          [_ | tail] = cwd
          tail

        subdir ->
          [subdir | cwd]
      end

    {new_cwd, tree}
  end

  # technically a no-op
  defp read_line({:cmd, :ls}, acc), do: acc

  defp read_line(entry, {cwd, tree}), do: {cwd, add_entry(tree, cwd, entry)}

  defp get_dir_sizes(tree) do
    for {dir, entries} <- tree, into: %{} do
      {dir,
       entries
       |> Enum.map(&size_of(tree, dir, &1))
       |> Enum.sum()}
    end
  end

  defp size_of(_tree, _cwd, {:file, _, file_size}), do: file_size

  defp size_of(tree, cwd, {:dir, dir_name}) do
    full_path = [dir_name | cwd]

    case tree[full_path] do
      nil ->
        0

      entries ->
        entries
        |> Enum.map(&size_of(tree, full_path, &1))
        |> Enum.sum()
    end
  end

  defp add_entry(map, key, value), do: Map.update(map, key, [value], &[value | &1])

  def size_of_dir_to_delete(dir_sizes) do
    root_size = dir_sizes[[]]
    size_to_free = @update_size - (@disk_size - root_size)

    dir_sizes
    |> Map.values()
    |> Enum.filter(&(&1 >= size_to_free))
    |> Enum.min()
  end
end

input = Day07.get_input()

IO.puts("Part 1: #{input |> Map.values() |> Enum.filter(&(&1 <= 100_000)) |> Enum.sum()}")
IO.puts("Part 2: #{input |> Day07.size_of_dir_to_delete()}")
