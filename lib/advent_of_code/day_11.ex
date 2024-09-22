defmodule AdventOfCode.Day11 do
  def power_level(sn, {x, y}) do
    p = ((x + 10) * y + sn) * (x + 10)
    rem(div(p, 100), 10) - 5
  end

  def precompute(sn) do
    for x <- 1..300, y <- 1..300, into: %{}, do: {{x, y}, power_level(sn, {x, y})}
  end

  def square({xc, yc}, c, memo) do
    Stream.flat_map(xc..(xc + c - 1), fn x -> Stream.map(yc..(yc + c - 1), fn y -> {x, y} end) end)
    |> Stream.map(&memo[&1])
    |> Enum.sum()
  end

  def part1(args) do
    memo = args |> String.trim() |> String.to_integer() |> precompute()

    for(x <- 1..(300 - 3), y <- 1..(300 - 3), do: {{x, y}, square({x, y}, 3, memo)})
    |> Enum.max_by(&elem(&1, 1))
    |> elem(0)
  end

  # Compute the sum of the right and bottom edge of a square
  # whose top left corner is at {x,y} and the side is c cells
  def edge(p, 1, memo), do: memo[p]

  def edge({xc, yc}, c, memo) do
    Enum.sum(for y <- yc..(yc + c - 1), do: memo[{xc + c - 1, y}]) +
      Enum.sum(for x <- xc..(xc + c - 2), do: memo[{x, yc + c - 1}])
  end

  def part2(args) do
    memo = args |> String.trim() |> String.to_integer() |> precompute()

    {xf, yf, cf, _} =
      for x <- 1..300, y <- 1..300 do
        {_, max_value, max_value_c} =
          Enum.reduce(
            1..min(300 - (x - 1), 300 - (y - 1)),
            {0, 0, 0},
            fn c, {c_sum, c_max, c_max_index} ->
              e = edge({x, y}, c, memo)
              new_sum = c_sum + e
              if new_sum > c_max, do: {new_sum, new_sum, c}, else: {new_sum, c_max, c_max_index}
            end
          )

        {x, y, max_value_c, max_value}
      end
      |> Enum.max_by(&elem(&1, 3))

    "#{xf},#{yf},#{cf}"
  end
end
