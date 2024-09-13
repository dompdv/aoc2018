defmodule AdventOfCode.Day03 do
  # Parse a line
  def parse(line) do
    [id, left, top, width, height] =
      Regex.scan(~r/#(\d+) @ (\d+),(\d+): (\d+)x(\d+)/, line, capture: :all_but_first)
      |> hd()
      |> Enum.map(&String.to_integer/1)

    # Create a nice Struct
    %{id: id, l: left, r: left + width - 1, t: top, b: top + height - 1}
  end

  # Intersection of 2 intervals [a,b] & [c,d]
  # order the two intervals
  def inter(a, b, c, d) when a > c, do: inter(c, d, a, b)
  # now a<=c
  # they don't intersect
  def inter(_a, b, c, _d) when c > b, do: []
  # they intersect
  def inter(_a, b, c, d), do: [c, min(b, d)]

  def overlap?({%{l: l1, r: r1, t: t1, b: b1}, %{l: l2, r: r2, t: t2, b: b2}}) do
    inter_h = inter(l1, r1, l2, r2)
    inter_v = inter(t1, b1, t2, b2)

    if inter_h != [] and inter_v != [] do
      {inter_h, inter_v}
    else
      false
    end
  end

  def generate({[l, r], [t, b]}) do
    for(x <- l..r, y <- t..b, do: {x, y})
    |> MapSet.new()
  end

  def part1(args) do
    claims = args |> String.split("\n", trim: true) |> Enum.map(&parse/1)
    # Create a cartesian product with Streams (to avoid creating it in memory)
    Stream.flat_map(claims, fn x -> Stream.map(claims, fn y -> {x, y} end) end)
    # Compare only ids once
    |> Stream.filter(fn {%{id: id1}, %{id: id2}} -> id1 < id2 end)
    |> Stream.map(&overlap?/1)
    |> Stream.filter(&(&1 != false))
    |> Enum.reduce(
      MapSet.new(),
      fn o_square, cells -> generate(o_square) |> MapSet.union(cells) end
    )
    |> MapSet.size()
  end

  def remove(s, {%{id: id1}, %{id: id2}}), do: s |> MapSet.delete(id1) |> MapSet.delete(id2)

  def part2(args) do
    # Parse claims
    claims = args |> String.split("\n", trim: true) |> Enum.map(&parse/1)

    # Create a set of all IDs
    all_ids = claims |> Enum.map(fn %{id: id} -> id end) |> MapSet.new()

    # Create a cartesian product with Streams (to avoid creating it in memory)
    Stream.flat_map(claims, fn x -> Stream.map(claims, fn y -> {x, y} end) end)
    # Compare only ids once
    |> Stream.filter(fn {%{id: id1}, %{id: id2}} -> id1 < id2 end)
    # Start with a set of all ids, and remove progressively the ids that overlap with another
    # there should be only one at the end
    |> Enum.reduce(
      all_ids,
      fn c, candidates ->
        if overlap?(c) != false, do: remove(candidates, c), else: candidates
      end
    )
  end
end
