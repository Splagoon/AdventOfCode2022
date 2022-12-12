defmodule Day11 do
  def get_input() do
    File.read!("data/11.txt")
    |> String.split("\n\n")
    |> Enum.map(&parse_monkey/1)
    |> Map.new(&{&1[:monkey], &1})
  end

  @monkey_regex ~r/Monkey (?<monkey_num>\d+):\n  Starting items: (?<starting_items>[^\n]+)\n  Operation: new = old (?<operation_operator>[-+*\/]) (?<operation_operand>[^\n]+)\n  Test: divisible by (?<test_divisor>\d+)\n    If true: throw to monkey (?<true_target>\d+)\n    If false: throw to monkey (?<false_target>\d+)/

  defp parse_monkey(input) do
    captures = Regex.named_captures(@monkey_regex, input)

    starting_items =
      captures["starting_items"]
      |> String.split(", ")
      |> Enum.map(&String.to_integer/1)

    operation_operand =
      case captures["operation_operand"] do
        "old" -> :old
        x -> String.to_integer(x)
      end

    %{
      monkey: String.to_integer(captures["monkey_num"]),
      items: starting_items,
      operation_operator: captures["operation_operator"],
      operation_operand: operation_operand,
      test_divisor: String.to_integer(captures["test_divisor"]),
      true_target: String.to_integer(captures["true_target"]),
      false_target: String.to_integer(captures["false_target"]),
      inspections: 0,
      # Caught items are placed at the _end_ of items, which is expensive,
      # so we store them separately to reduce list concats
      caught_items: []
    }
  end

  def do_rounds(monkeys, _part, 0), do: monkeys

  def do_rounds(monkeys, part, num_rounds) do
    new_monkeys = do_round(monkeys, part)
    do_rounds(new_monkeys, part, num_rounds - 1)
  end

  defp do_round(monkeys, part) do
    for monkey <- Map.keys(monkeys), reduce: monkeys do
      current_monkeys ->
        inspect_items(current_monkeys[monkey], current_monkeys, part)
    end
  end

  defp inspect_items(%{items: [], caught_items: []}, monkeys, _), do: monkeys

  defp inspect_items(
         monkey = %{items: [], caught_items: caught_items, monkey: monkey_num},
         monkeys,
         part
       ) do
    # Place caught items in inventory
    new_monkey = %{
      monkey
      | items: Enum.reverse(caught_items),
        caught_items: []
    }

    new_monkeys = Map.replace!(monkeys, monkey_num, new_monkey)

    inspect_items(new_monkey, new_monkeys, part)
  end

  defp inspect_items(monkey = %{items: [item | next_items], monkey: monkey_num}, monkeys, part) do
    new_monkey = %{
      monkey
      | items: next_items,
        inspections: monkey[:inspections] + 1
    }

    operand =
      case monkey[:operation_operand] do
        :old -> item
        x -> x
      end

    operator_result = do_operator(item, monkey[:operation_operator], operand)

    # I hate math
    supermodulo = supermodulo(monkeys)

    new_item =
      rem(
        if part == :part1 do
          div(operator_result, 3)
        else
          operator_result
        end,
        supermodulo
      )

    target_monkey =
      monkey[if(rem(new_item, monkey[:test_divisor]) == 0, do: :true_target, else: :false_target)]

    new_monkeys =
      monkeys
      |> Map.update!(
        target_monkey,
        &%{&1 | caught_items: [new_item | &1[:caught_items]]}
      )
      |> Map.replace!(monkey_num, new_monkey)

    inspect_items(new_monkey, new_monkeys, part)
  end

  defp do_operator(lhs, "+", rhs), do: lhs + rhs
  defp do_operator(lhs, "-", rhs), do: lhs - rhs
  defp do_operator(lhs, "*", rhs), do: lhs * rhs
  defp do_operator(lhs, "/", rhs), do: div(lhs, rhs)

  def monkey_business(monkeys) do
    monkeys
    |> Map.values()
    |> Enum.map(&Map.get(&1, :inspections))
    |> Enum.sort(:desc)
    |> Enum.take(2)
    |> Enum.reduce(&(&1 * &2))
  end

  def supermodulo(monkeys) do
    monkeys
    |> Map.values()
    |> Enum.map(&Map.get(&1, :test_divisor))
    |> Enum.reduce(&(&1 * &2))
  end
end

input = Day11.get_input()

IO.puts("Part 1: #{input |> Day11.do_rounds(:part1, 20) |> Day11.monkey_business()}")
IO.puts("Part 2: #{input |> Day11.do_rounds(:part2, 10_000) |> Day11.monkey_business()}")
