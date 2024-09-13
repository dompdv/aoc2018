defmodule AdventOfCode.Day04 do
  ## Parsing
  @reg1 ~r/\[(\d+)-(\d+)-(\d+) (\d+):(\d+)\] falls asleep/
  @reg2 ~r/\[(\d+)-(\d+)-(\d+) (\d+):(\d+)\] wakes up/
  @reg3 ~r/\[(\d+)-(\d+)-(\d+) (\d+):(\d+)\] Guard #(\d+) begins shift/

  def parse_item(tag, [[_ | l]]) do
    [y, mo, d, h, mi | r] = Enum.map(l, &String.to_integer/1)
    {:ok, d} = NaiveDateTime.new(y, mo, d, h, mi, 0)
    # Returns a triplet {:up or :begin or :fall, date, guard number if any}
    if r == [], do: {tag, d, nil}, else: {tag, d, hd(r)}
  end

  def parse(line) do
    cond do
      Regex.match?(@reg1, line) ->
        parse_item(:fall, Regex.scan(@reg1, line))

      Regex.match?(@reg2, line) ->
        parse_item(:up, Regex.scan(@reg2, line))

      Regex.match?(@reg3, line) ->
        parse_item(:begin, Regex.scan(@reg3, line))
    end
  end

  # Regroups the ordered list by packet of consecutive lines related to one guard shift
  # Need 2 accumulators: one for one guard shift and one for all the shifts

  # Start of the recursion: should be a guard shift
  def group_by_shifts([{:begin, d, guard} | r]),
    do: group_by_shifts(r, guard, [{:up, d, nil}], [])

  # last == the current guard ID
  # acc_guard == the accumulator for the guard shift
  # acc_groups == the accumulator for all the shifts
  # End of the list, we pack  the 2 accumulators up , at the same time
  def group_by_shifts([], last, acc_guard, acc_groups),
    do: [{last, Enum.reverse(acc_guard)} | acc_groups] |> Enum.reverse()

  # Start of a shift, we pack the previous one and start a new one
  def group_by_shifts([{:begin, d, guard} | r], last, acc_guard, acc_groups) do
    group_by_shifts(r, guard, [{:up, d, nil}], [{last, Enum.reverse(acc_guard)} | acc_groups])
  end

  # accumulate in the same guard shift
  def group_by_shifts([o | r], last, acc_guard, acc_group) do
    group_by_shifts(r, last, [o | acc_guard], acc_group)
  end

  ## Process a shift. List all the minutes when the gaurd was asleep during his shift
  def asleep(l), do: asleep(l, [])

  def asleep([], s), do: List.flatten(s)

  # Consider only a :fall followed by a :up
  def asleep([{:fall, d1, _}, {:up, d2, _} | r], s) do
    {m1, m2} = {d1.minute, d2.minute - 1}
    asleep(r, [Enum.to_list(m1..m2) | s])
  end

  # Else go to the next line
  def asleep([_ | r], s), do: asleep(r, s)

  def parse_and_process(args) do
    # Parse
    args
    |> String.split("\n", trim: true)
    |> Enum.map(&parse/1)
    # Sort the observations
    |> Enum.sort(fn {_, d1, _}, {_, d2, _} -> NaiveDateTime.compare(d1, d2) == :lt end)
    # Group by shifts
    |> group_by_shifts()
    # Process each shift
    |> Enum.map(fn {guard, group} -> {guard, asleep(group)} end)
  end

  def part1(args) do
    groups = parse_and_process(args)

    # Find the sleepy guard
    {sleepy_guard, _} =
      groups
      # Consider the time spent sleeping
      |> Enum.map(fn {guard, group} -> {guard, Enum.count(group)} end)
      # Regroup all the shifts for each guard
      |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
      # For each guard, sum  the total time sleeping
      |> Enum.map(fn {k, l} -> {k, Enum.sum(l)} end)
      # Find the guard that sleeps the most
      |> Enum.max_by(&elem(&1, 1))

    # Find the minute the sleepy guard sleeps the most
    {most_minute, _} =
      groups
      # Keep only the shifts of the sleepy guard
      |> Enum.filter(&(elem(&1, 0) == sleepy_guard))
      # Create a list of all the sleeping minutes over all shifts
      |> Enum.map(&elem(&1, 1))
      |> List.flatten()
      # Identify the most frequent minute
      |> Enum.frequencies()
      |> Enum.max_by(&elem(&1, 1))

    sleepy_guard * most_minute
  end

  def part2(args) do
    {guard, {max_minute, _}} =
      parse_and_process(args)
      # Regroup all the shifts of each guard and consolidate the list of sleeping minutes for each guard
      |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
      |> Enum.map(fn {g, l} -> {g, l |> List.flatten()} end)
      # Do not consider the guards who never sleep
      |> Enum.filter(&(elem(&1, 1) != []))
      # Select, for each guard, the most frequent minute
      |> Enum.map(fn {g, l} -> {g, l |> Enum.frequencies() |> Enum.max_by(&elem(&1, 1))} end)
      # Find the winner guard
      |> Enum.max_by(fn {_, {_, m}} -> m end)

    guard * max_minute
  end
end
