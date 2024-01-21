defmodule AdventOfCode.Day11 do
  def power(x, y, sn) do
    rack_id = x + 10
    rem(div((rack_id * y + sn) * rack_id, 100), 10) - 5
  end

  def part1(args) do
    gird_sn = args |> String.trim() |> String.to_integer()
    sq = for dx <- 0..2, dy <- 0..2, do: {dx, dy}

    for(x <- 1..298, y <- 1..298, do: {x, y})
    |> Enum.reduce({nil, nil, nil}, fn {x, y}, {xm, ym, maxf} ->
      sq_power = for({dx, dy} <- sq, do: power(x + dx, y + dy, gird_sn)) |> Enum.sum()
      if maxf == nil or sq_power > maxf, do: {x, y, sq_power}, else: {xm, ym, maxf}
    end)
  end

  def part2(args) do
    gird_sn = args |> String.trim() |> String.to_integer()
    grid_sn = 18
  end
end
