defmodule AdventOfCode.Day16 do
  def clean_list(l) do
    l
    |> String.replace("Before: [", "")
    |> String.replace("After:  [", "")
    |> String.replace(",", "")
    |> String.replace("]", "")
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end

  def parse_log_line(triplet) do
    triplet |> Enum.map(&clean_list/1)
  end

  def parse_log(log) do
    log |> String.split("\n", trim: true) |> Enum.chunk_every(3) |> Enum.map(&parse_log_line/1)
  end

  def parse(args) do
    [log, pgm] = args |> String.split("\n\n\n", trim: true)
    parse_log(log)
  end

  def part1(args) do
    args |> parse()
  end

  def part2(args) do
    args
  end
end
