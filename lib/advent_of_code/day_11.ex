defmodule AdventOfCode.Day11 do
  def power_level(sn, {x, y}) do
    p = ((x + 10) * y + sn) * (x + 10)
    rem(div(p, 100), 10) - 5
  end

  def square({xc, yc}, c, memo) do
    Stream.flat_map(xc..(xc + c - 1), fn x -> Stream.map(yc..(yc + c - 1), fn y -> {x, y} end) end)
    |> Stream.map(&memo[&1])
    |> Enum.sum()
  end

  def part1(args) do
    sn = args |> String.trim() |> String.to_integer()
    memo = for x <- 1..300, y <- 1..300, into: %{}, do: {{x, y}, power_level(sn, {x, y})}

    for(x <- 1..(300 - 3), y <- 1..(300 - 3), do: {{x, y}, square({x, y}, 3, memo)})
    |> Enum.max_by(&elem(&1, 1))
    |> elem(0)
  end

  def part2(args) do
    sn = args |> String.trim() |> String.to_integer()
    for(x <- 1..300, y <- 1..300, do: power_level(sn, {x, y})) |> Enum.sum()
  end
end
