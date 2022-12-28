defmodule Day16 do
  @line_regex ~r/Valve (..) has flow rate=(\d+); tunnels? leads? to valves? (.+)/

  def get_input() do
    valves =
      File.stream!("data/16.txt")
      |> Enum.map(&parse_line/1)
      |> Map.new()

    valve_paths =
      for valve <- Map.keys(valves), reduce: %{} do
        map -> find_paths_from_valve(valves, valve, [[valve]], map)
      end

    {valves, valve_paths}
  end

  defp parse_line(line) do
    [_, valve_name, flow_rate, neighbors] = Regex.run(@line_regex, line)

    {valve_name,
     %{flow_rate: String.to_integer(flow_rate), neighbors: String.split(neighbors, ", ")}}
  end

  defp find_paths_from_valve(_, _, [], path_map), do: path_map

  defp find_paths_from_valve(
         valves,
         starting_valve,
         [current_path = [current_valve | _] | remaining_paths],
         path_map
       ) do
    path_key = {starting_valve, current_valve}

    if Map.has_key?(path_map, path_key) and length(path_map[path_key]) < length(current_path) - 1 do
      find_paths_from_valve(valves, starting_valve, remaining_paths, path_map)
    else
      new_path_map = Map.put(path_map, path_key, current_path |> Enum.reverse() |> Enum.drop(1))
      new_paths = valves[current_valve].neighbors |> Enum.map(&[&1 | current_path])
      find_paths_from_valve(valves, starting_valve, new_paths ++ remaining_paths, new_path_map)
    end
  end

  # thanks simon
  defp find_partitions([]), do: [{[], []}]

  defp find_partitions([x | xs]) do
    rest = find_partitions(xs)
    in_first = Enum.map(rest, fn {p1, p2} -> {[x | p1], p2} end)
    in_second = Enum.map(rest, fn {p1, p2} -> {p1, [x | p2]} end)
    in_first ++ in_second
  end

  def best_pressure_released(input = {valves, _valve_paths}, :part1) do
    # Only consider opening valves with nonzero flow rate
    unopened_valves =
      valves
      |> Map.keys()
      |> Enum.filter(&(valves[&1].flow_rate > 0))

    best_permutation(input, "AA", unopened_valves, 0, 0, 30)
  end

  def best_pressure_released(input = {valves, _valve_paths}, :part2) do
    # Only consider opening valves with nonzero flow rate
    unopened_valves =
      valves
      |> Map.keys()
      |> Enum.filter(&(valves[&1].flow_rate > 0))

    # Assumption: we're each going to have to open at least 40% of valves
    min_valves_to_open = floor(length(unopened_valves) * 0.4)

    unopened_valve_partitions =
      find_partitions(unopened_valves)
      |> Enum.filter(fn {my_partition, elephant_parition} ->
        length(my_partition) > min_valves_to_open and
          length(elephant_parition) > min_valves_to_open
      end)

    best_paths =
      unopened_valve_partitions
      |> Enum.map(&elem(&1, 0))
      |> Map.new(&{&1, best_permutation(input, "AA", &1, 0, 0, 26)})

    unopened_valve_partitions
    |> Enum.map(fn {my_valves, elephant_valves} ->
      best_paths[my_valves] + best_paths[elephant_valves]
    end)
    |> Enum.max()
  end

  defp best_permutation(
         _input,
         _current_valve,
         [],
         pressure_released,
         pressure_rate,
         minutes_remaining
       ),
       do: pressure_released + pressure_rate * minutes_remaining

  defp best_permutation(
         input = {valves, valve_paths},
         current_valve,
         unopened_valves,
         pressure_released,
         pressure_rate,
         minutes_remaining
       ) do
    for unopened_valve <- unopened_valves, reduce: 0 do
      best ->
        move_steps = valve_paths[{current_valve, unopened_valve}]
        minutes_passed = length(move_steps) + 1
        new_minutes_remaining = minutes_remaining - minutes_passed

        if new_minutes_remaining < 0 do
          # Not enough time to open any more valves
          best_permutation(
            input,
            current_valve,
            [],
            pressure_released,
            pressure_rate,
            minutes_remaining
          )
        else
          new_unopened_valves = unopened_valves -- [unopened_valve]
          new_pressure_released = pressure_released + pressure_rate * minutes_passed
          new_pressure_rate = pressure_rate + valves[unopened_valve].flow_rate

          best_permutation(
            input,
            unopened_valve,
            new_unopened_valves,
            new_pressure_released,
            new_pressure_rate,
            new_minutes_remaining
          )
        end
        |> max(best)
    end
  end
end

input = Day16.get_input()

IO.puts("Part 1: #{Day16.best_pressure_released(input, :part1)}")
IO.puts("Part 2: #{Day16.best_pressure_released(input, :part2)}")
