defmodule Day13 do
  def get_input() do
    File.read!("data/13.txt")
    |> String.split("\n\n")
    |> Enum.map(fn pair ->
      pair
      |> String.split("\n")
      |> Enum.filter(&(&1 != ""))
      |> Enum.map(&String.to_charlist/1)
      |> Enum.map(&tokenize/1)
      |> Enum.map(&parse/1)
      |> List.to_tuple()
    end)
  end

  defp tokenize(str) do
    read_token(str, nil, [])
  end

  defp read_token([], _, tokens), do: Enum.reverse(tokens)

  defp read_token([char | remaining_chars], nil, tokens) do
    case char do
      c when c in ?0..?9 ->
        read_token(remaining_chars, [c], tokens)

      ?\[ ->
        read_token(remaining_chars, nil, [:start_list | tokens])

      ?\] ->
        read_token(remaining_chars, nil, [:end_list | tokens])

      ?, ->
        read_token(remaining_chars, nil, tokens)
    end
  end

  defp read_token(chars = [char | remaining_chars], int_in_progress, tokens) do
    case char do
      c when c in ?0..?9 ->
        read_token(remaining_chars, [c | int_in_progress], tokens)

      _ ->
        int = int_in_progress |> Enum.reverse() |> to_string() |> String.to_integer()
        read_token(chars, nil, [{:int, int} | tokens])
    end
  end

  defp parse([:start_list | tokens]) do
    {result, _} = parse_list(tokens, [])
    result
  end

  defp parse_list([token | remaining_tokens], result) do
    case token do
      :start_list ->
        {list, remaining_tokens} = parse_list(remaining_tokens, [])
        parse_list(remaining_tokens, [list | result])

      :end_list ->
        {Enum.reverse(result), remaining_tokens}

      {:int, int} ->
        parse_list(remaining_tokens, [int | result])
    end
  end

  def compare([], []), do: :eq
  def compare([], [_]), do: :lt
  def compare([_], []), do: :gt

  def compare([a | remaining_a], [b | remaining_b]) do
    case compare(a, b) do
      :eq -> compare(remaining_a, remaining_b)
      other -> other
    end
  end

  def compare(a, b) when is_list(a), do: compare(a, [b])
  def compare(a, b) when is_list(b), do: compare([a], b)

  def compare(a, b) do
    cond do
      a < b -> :lt
      a > b -> :gt
      a == b -> :eq
    end
  end
end

pairwise_input = Day13.get_input()
divider_packets = [[[2]], [[6]]]

right_indexes =
  pairwise_input
  |> Enum.with_index(fn {a, b}, i -> {i + 1, Day13.compare(a, b)} end)
  |> Enum.filter(fn {_, result} -> result == :lt end)
  |> Enum.map(&elem(&1, 0))

IO.puts("Part 1: #{right_indexes |> Enum.sum()}")

decoder_key =
  pairwise_input
  |> Enum.flat_map(&Tuple.to_list/1)
  |> Enum.concat(divider_packets)
  |> Enum.sort(Day13)
  |> Enum.with_index(fn l, i -> {i + 1, l} end)
  |> Enum.filter(fn {_, l} ->
    l in divider_packets
  end)
  |> Enum.map(&elem(&1, 0))
  |> Enum.reduce(&*/2)

IO.puts("Part 2: #{decoder_key}")
