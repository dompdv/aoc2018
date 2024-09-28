defmodule AdventOfCode.Day14 do
  def parse(args), do: args |> String.trim() |> String.to_integer()

  def cook({recipes, elf1, elf2}) do
    v = recipes[elf1] + recipes[elf2]
    last_index = map_size(recipes)

    {recipes, last_index} =
      if div(v, 10) > 0,
        do: {Map.put(recipes, last_index, div(v, 10)), last_index + 1},
        else: {recipes, last_index}

    {recipes, last_index} = {Map.put(recipes, last_index, rem(v, 10)), last_index + 1}
    elf1 = rem(elf1 + recipes[elf1] + 1, last_index)
    elf2 = rem(elf2 + recipes[elf2] + 1, last_index)
    {recipes, elf1, elf2}
  end

  def initial_state(), do: {%{0 => 3, 1 => 7}, 0, 1}

  def part1(args) do
    rounds = args |> parse()

    {r, _, _} = Enum.reduce(1..rounds, initial_state(), fn _, s -> cook(s) end)
    for(s <- rounds..(rounds + 9), do: Integer.to_string(r[s])) |> Enum.join()
  end

  def print({r, e1, e2} = s, n) do
    for i <- (map_size(r) - n)..(map_size(r) - 1) do
      cond do
        i == e1 -> "(#{r[i]}) "
        i == e2 -> "[#{r[i]}] "
        true -> " #{r[i]}  "
      end
    end
    |> Enum.join()
    |> IO.puts()

    s
  end

  def part2(args) do
    args = "59414"
    target = args |> String.trim() |> to_charlist() |> Enum.map(&(&1 - ?0))
    len_target = length(target)

    Stream.iterate(0, &(&1 + 1))
    |> Enum.reduce_while(
      initial_state(),
      fn i, s ->
        new_s = cook(s)
        r = elem(new_s, 0)
        t = map_size(r)
        tail = for i <- (t - len_target)..(t - 1), do: r[i]
        if tail == target, do: {:halt, new_s}, else: {:cont, new_s}
      end
    )
    |> elem(0)
    |> map_size()
    |> then(&(&1 - len_target))
  end
end
