defmodule Day15 do
  @input_regex ~r/Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)/
  @grid_size 4_000_000

  def get_input() do
    sensors =
      File.read!("data/15.txt")
      |> String.split("\n")
      |> Enum.filter(&(&1 != ""))
      |> Enum.map(&parse_line/1)

    coverage =
      sensors
      |> Enum.reduce(Map.new(), &coverage_by_row/2)

    beacons =
      sensors
      |> Enum.map(&Map.get(&1, :beacon))
      |> MapSet.new()

    {coverage, beacons}
  end

  defp parse_line(line) do
    [_ | coords] = Regex.run(@input_regex, line)
    [sensor_x, sensor_y, beacon_x, beacon_y] = coords |> Enum.map(&String.to_integer/1)
    sensor_pos = {sensor_x, sensor_y}
    beacon_pos = {beacon_x, beacon_y}
    %{sensor: sensor_pos, beacon: beacon_pos, radius: distance(sensor_pos, beacon_pos)}
  end

  defp coverage_by_row(%{sensor: {sensor_x, sensor_y}, radius: sensor_radius}, coverage_by_rows) do
    for dy <- -sensor_radius..sensor_radius, reduce: coverage_by_rows do
      coverage ->
        x_offset = sensor_radius - abs(dy)
        range = (sensor_x - x_offset)..(sensor_x + x_offset)
        Map.update(coverage, sensor_y + dy, [range], &[range | &1])
    end
  end

  defp distance({x1, y1}, {x2, y2}), do: abs(x1 - x2) + abs(y1 - y2)

  def count_beaconless_columns(coverage, beacons, y) do
    beacons =
      beacons
      |> Enum.filter(fn {_bx, by} -> y == by end)
      |> Enum.map(&elem(&1, 0))
      |> MapSet.new()

    for range <- Map.get(coverage, y), reduce: MapSet.new() do
      set ->
        for x <- range, reduce: set do
          set -> MapSet.put(set, x)
        end
    end
    |> MapSet.difference(beacons)
    |> MapSet.size()
  end

  def tuning_frequency({x, y}), do: x * 4_000_000 + y

  def find_beacon(coverage) do
    beacon_search({0, 0}, Map.get(coverage, 0), coverage)
  end

  defp beacon_search(pos, [], _coverage), do: pos

  defp beacon_search(
         pos = {x, y},
         [coverage_range = _coverage_start..coverage_end | remaining_ranges],
         coverage
       ) do
    if x in coverage_range do
      next_pos =
        {_, next_y} = if(coverage_end <= @grid_size, do: {coverage_end + 1, y}, else: {0, y + 1})

      beacon_search(next_pos, Map.get(coverage, next_y), coverage)
    else
      beacon_search(pos, remaining_ranges, coverage)
    end
  end
end

{coverage, beacons} = Day15.get_input()

IO.puts("Part 1: #{Day15.count_beaconless_columns(coverage, beacons, 2_000_000)}")
IO.puts("Part 2: #{coverage |> Day15.find_beacon() |> Day15.tuning_frequency()}")
