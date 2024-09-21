defmodule AdventOfCode.Day11 do
  def power_level(sn, {x, y}) do
    p = ((x + 10) * y + sn) * (x + 10)
    rem(div(p, 100), 10) - 5
  end

  def power_level(sn, p, memo) do
    case Map.get(memo, p) do
      nil ->
        v = power_level(sn, p)
        {v, Map.put(memo, p, v)}

      v ->
        {v, memo}
    end
  end

  def square(sn, {xc, yc}, c, memo) do
    Stream.flat_map(xc..(xc + c - 1), fn x -> Stream.map(yc..(yc + c - 1), fn y -> {x, y} end) end)
    |> Enum.reduce(
      {0, memo},
      fn p, {total, c_memo} ->
        {power, new_memo} = power_level(sn, p, c_memo)
        {total + power, new_memo}
      end
    )
  end

  def part1(args) do
    sn = args |> String.trim() |> String.to_integer()
    memo = for x <- 1..300, y <- 1..300, into: %{}, do: {{x, y}, power_level(sn, {x, y})}
    c = 3

    Stream.flat_map(1..(300 - c), fn x -> Stream.map(1..(300 - c), fn y -> {x, y} end) end)
    |> Enum.reduce(
      {0, nil, %{}},
      fn p, {current_max, current_pos} ->
        {square_value, new_memo} = square(sn, p, c, memo)

        if square_value > current_max,
          do: {square_value, p, new_memo},
          else: {current_max, current_pos, new_memo}
      end
    )
    |> elem(1)
  end

  def part2(args) do
    sn = args |> String.trim() |> String.to_integer()
    for(x <- 1..300, y <- 1..300, do: power_level(sn, {x, y})) |> Enum.sum()
  end
end
