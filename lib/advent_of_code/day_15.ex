defmodule AdventOfCode.Day15 do
  def to_grid(args) do
    args
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, y} ->
      Enum.map(line |> String.graphemes() |> Enum.with_index(), fn {c, x} -> {{x, y}, c} end)
    end)
  end

  def parse(args) do
    args
    |> to_grid()
    |> Enum.reduce(
      {[], [], []},
      fn {pos, c}, {blocks, elves, gobs} = acc ->
        case c do
          "." -> acc
          "#" -> {[pos | blocks], elves, gobs}
          "E" -> {blocks, [pos | elves], gobs}
          "G" -> {blocks, elves, [pos | gobs]}
        end
      end
    )
  end

  def part1(args) do
    args |> parse()
  end

  def part2(args) do
    args
  end

  def test(_) do
    """
    #########
    #G..G..G#
    #.......#
    #.......#
    #G..E..G#
    #.......#
    #.......#
    #G..G..G#
    #########
    """
  end
end
