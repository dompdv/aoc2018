defmodule AdventOfCode.Day14 do
  def parse(args), do: args |> String.trim() |> String.to_integer()

  # n is a number
  # i : i-th number of the decimal representation of n, starting from 0 = most significant digit
  def extract(n, n_digits, i) do
    l = n_digits - (i + 1)
    rem(div(n, Integer.pow(10, l)), 10)
  end

  def cook({recipes, n_digits, elf1, elf2}) do
    v = extract(recipes, n_digits, elf1) + extract(recipes, n_digits, elf2)

    {recipes, n_digits} =
      if div(v, 10) > 0,
        do: {recipes * 100 + v, n_digits + 2},
        else: {recipes * 10 + v, n_digits + 1}

    elf1 = rem(elf1 + extract(recipes, n_digits, elf1) + 1, n_digits)
    elf2 = rem(elf2 + extract(recipes, n_digits, elf2) + 1, n_digits)
    {recipes, n_digits, elf1, elf2}
  end

  def initial_state(), do: {37, 2, 0, 1}

  def part1(args) do
    rounds = args |> parse()

    {r, n_digits, _, _} =
      Stream.iterate(0, &(&1 + 1))
      |> Enum.reduce_while(
        initial_state(),
        fn i, s ->
          {r, n_digits, _, _} = new_s = cook(s)
          IO.inspect(new_s)
          if i > 10, do: raise("strop")

          if n_digits > rounds + 20,
            do: {:halt, new_s},
            else: {:cont, new_s}
        end
      )

    for(s <- rounds..(rounds + 9), do: extract(r, n_digits, s))
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
