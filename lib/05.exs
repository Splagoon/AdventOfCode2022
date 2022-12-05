defmodule Day05 do
  @stack_regex ~r/(\[\w\]|\s{3})(?:\s|$)/
  @instruction_regex ~r/^move (\d+) from (\d) to (\d)$/

  def get_input() do
    [initial_state, instructions] =
      File.read!("data/05.txt")
      |> String.split("\n\n")

    # I will not remember how this works an hour from now
    stacks =
      initial_state
      |> String.split("\n")
      |> Enum.map(fn row ->
        Regex.scan(@stack_regex, row)
        |> Enum.map(&parse_row/1)
      end)
      |> Enum.split(-1)
      |> elem(0)
      |> Enum.zip()
      |> Enum.map(fn col ->
        col
        |> Tuple.to_list()
        |> Enum.filter(&(&1 != nil))
      end)

    instructions =
      instructions
      |> String.split("\n")
      |> Enum.filter(&(&1 != ""))
      |> Enum.map(fn line ->
        [_ | nums] = Regex.run(@instruction_regex, line)
        [move, from, to] = nums |> Enum.map(&String.to_integer/1)
        %{move: move, from: from, to: to}
      end)

    {stacks, instructions}
  end

  defp parse_row([_, capture]) do
    case String.to_charlist(capture) do
      [?\[, name, ?\]] -> name
      _ -> nil
    end
  end

  def execute_part1(stacks, instructions) do
    Enum.reduce(instructions, stacks, &execute_instruction_part1/2)
  end

  defp execute_instruction_part1(%{move: 0}, stacks), do: stacks

  defp execute_instruction_part1(instruction = %{move: move, from: from, to: to}, stacks) do
    stacks_by_num =
      Enum.zip([1..length(stacks), stacks])
      |> Map.new()

    [moved_box | remaining_boxes] = stacks_by_num[from]

    new_stacks =
      for i <- 1..length(stacks) do
        case i do
          ^from -> remaining_boxes
          ^to -> [moved_box | stacks_by_num[i]]
          _ -> stacks_by_num[i]
        end
      end

    execute_instruction_part1(%{instruction | move: move - 1}, new_stacks)
  end

  def execute_part2(stacks, instructions) do
    Enum.reduce(instructions, stacks, &execute_instruction_part2/2)
  end

  defp execute_instruction_part2(%{move: move, from: from, to: to}, stacks) do
    stacks_by_num =
      Enum.zip([1..length(stacks), stacks])
      |> Map.new()

    {moved_boxes, remaining_boxes} = Enum.split(stacks_by_num[from], move)

    for i <- 1..length(stacks) do
      case i do
        ^from -> remaining_boxes
        ^to -> moved_boxes ++ stacks_by_num[i]
        _ -> stacks_by_num[i]
      end
    end
  end
end

{stacks, instructions} = Day05.get_input()

IO.puts("Part 1: #{stacks |> Day05.execute_part1(instructions) |> Enum.map(&List.first/1)}")
IO.puts("Part 2: #{stacks |> Day05.execute_part2(instructions) |> Enum.map(&List.first/1)}")
