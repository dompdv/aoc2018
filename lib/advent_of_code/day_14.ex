defmodule AdventOfCode.Day14 do
  # One turn
  def cook({recipes, elf1, elf2}) do
    # New recipe score
    v = recipes[elf1] + recipes[elf2]
    size = map_size(recipes)
    # Split units and "dizaines"
    units = rem(v, 10)
    diz = div(v, 10)

    # Add them at the end of the map
    new_recipes =
      if diz > 0,
        do: recipes |> Map.put(size, diz) |> Map.put(size + 1, units),
        else: recipes |> Map.put(size, units)

    # Adjust the elves' positions
    new_size = map_size(new_recipes)
    new_elf1 = rem(elf1 + new_recipes[elf1] + 1, new_size)
    new_elf2 = rem(elf2 + new_recipes[elf2] + 1, new_size)
    {new_recipes, new_elf1, new_elf2}
  end

  # The state is {a map of the recipes' scores, position of elf 1, position of elf 2}
  def initial_state(), do: {%{0 => 3, 1 => 7}, 0, 1}

  def part1(args) do
    rounds = args |> String.trim() |> String.to_integer()

    # Take some margin (number of rounds to compute to be sure)
    {r, _, _} = Enum.reduce(1..(rounds * 2), initial_state(), fn _, s -> cook(s) end)
    for(s <- rounds..(rounds + 9), do: Integer.to_string(r[s])) |> Enum.join()
  end

  def search(s, target, len_target) do
    {r, _, _} = new_s = cook(s)
    t = map_size(r)
    tail1 = for i <- (t - len_target)..(t - 1), do: r[i]
    tail2 = for i <- (t - len_target - 1)..(t - 2), do: r[i]

    cond do
      tail1 == target -> map_size(r) - len_target
      tail2 == target -> map_size(r) - len_target - 1
      true -> search(new_s, target, len_target)
    end
  end

  def part2(args) do
    target = args |> String.trim() |> to_charlist() |> Enum.map(&(&1 - ?0))
    len_target = length(target)
    search(initial_state(), target, len_target)
  end
end
