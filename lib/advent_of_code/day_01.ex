defmodule AdventOfCode.Day01 do
  def part1(args) do
    args |> String.split() |> Enum.map(&String.to_integer/1) |> Enum.sum()
  end

  def part2(args) do
    # Parsing
    args
    |> String.split()
    |> Enum.map(&String.to_integer/1)
    # Cycle potentially infinitely
    |> Stream.cycle()
    # Keep track of the frequencies already seen in a set()
    |> Enum.reduce_while(
      # current frequency, set of seen frequencies
      {0, MapSet.new()},
      fn df, {current_freq, seen} ->
        new_freq = current_freq + df

        if MapSet.member?(seen, new_freq),
          do: {:halt, new_freq},
          else: {:cont, {new_freq, MapSet.put(seen, new_freq)}}
      end
    )
  end
end
