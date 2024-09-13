defmodule AdventOfCode.Day02 do
  def part1(args) do
    args
    |> String.split()
    |> Enum.reduce(
      # {count of 2s, count of 3s}
      {0, 0},
      fn s, {s1, s2} ->
        # letter frequencies with an ID
        counts =
          s
          |> String.graphemes()
          |> Enum.frequencies()
          |> Map.values()

        {s1 + if(2 in counts, do: 1, else: 0), s2 + if(3 in counts, do: 1, else: 0)}
      end
    )
    # Mutiply
    |> then(fn {a, b} -> a * b end)
  end

  def compare_ids({{s1, _}, {s2, _}}) do
    # Count the number of differing letters
    for({a, b} <- Enum.zip(s1, s2), a != b, do: 1)
    |> Enum.sum()
    # if diff == 1, create the list of common letters
    |> then(fn diff ->
      if diff == 1 do
        for({a, b} <- Enum.zip(s1, s2), a == b, do: a) |> Enum.join()
      else
        false
      end
    end)
  end

  def part2(args) do
    # For each string, convert it into a list of characters and add an index (to avoid later to compare twice the same two ids and an id to itself)
    ids = args |> String.split() |> Enum.map(&String.graphemes/1) |> Enum.with_index()
    # Create a cartesian product with Streams (to avoid creating it in memory)
    Stream.flat_map(ids, fn x -> Stream.map(ids, fn y -> {x, y} end) end)
    # Compare only ids once
    |> Stream.filter(fn {{_, id1}, {_, id2}} -> id1 < id2 end)
    # Compare them
    |> Stream.map(&compare_ids/1)
    # Keep only the matches
    |> Stream.filter(&(&1 != false))
    # Take the first (and only) solution
    |> Enum.take(1)
    |> hd()
  end
end
