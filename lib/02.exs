defmodule Day02 do
  @winning_moves %{rock: :paper, paper: :scissors, scissors: :rock}
  @losing_moves %{rock: :scissors, paper: :rock, scissors: :paper}

  @move_scores %{rock: 1, paper: 2, scissors: 3}
  @result_scores %{lose: 0, draw: 3, win: 6}

  @lhs_to_move %{a: :rock, b: :paper, c: :scissors}
  @rhs_to_move %{x: :rock, y: :paper, z: :scissors}
  @rhs_to_result %{x: :lose, y: :draw, z: :win}

  def get_input() do
    File.read!("data/02.txt")
    |> String.split("\n")
    |> Enum.map(&String.to_charlist/1)
    |> Enum.reduce([], &parse_line/2)
  end

  # Parse lines like 'A X'
  defp parse_line([left, ?\s, right], parsed_lines) do
    lhs =
      case left do
        ?A -> :a
        ?B -> :b
        ?C -> :c
      end

    rhs =
      case right do
        ?X -> :x
        ?Y -> :y
        ?Z -> :z
      end

    [{lhs, rhs} | parsed_lines]
  end

  # Skip empty lines
  defp parse_line([], parsed_lines), do: parsed_lines

  defp get_result({your_move, their_move}) do
    winning_move = @winning_moves[their_move]

    case your_move do
      ^winning_move -> :win
      ^their_move -> :draw
      _ -> :lose
    end
  end

  defp move_for_result(their_move, :draw), do: their_move
  defp move_for_result(their_move, :win), do: @winning_moves[their_move]
  defp move_for_result(their_move, :lose), do: @losing_moves[their_move]

  def part1({their_input, your_input}) do
    their_move = @lhs_to_move[their_input]
    your_move = @rhs_to_move[your_input]
    result = get_result({your_move, their_move})
    @move_scores[your_move] + @result_scores[result]
  end

  def part2({their_input, result_input}) do
    desired_result = @rhs_to_result[result_input]
    their_move = @lhs_to_move[their_input]
    your_move = move_for_result(their_move, desired_result)
    @move_scores[your_move] + @result_scores[desired_result]
  end
end

input = Day02.get_input()

IO.puts("Part 1: #{input |> Enum.map(&Day02.part1/1) |> Enum.sum()}")
IO.puts("Part 2: #{input |> Enum.map(&Day02.part2/1) |> Enum.sum()}")
