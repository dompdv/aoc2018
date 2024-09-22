defmodule AdventOfCode.Day12 do
  @target 50_000_000_000
  def parse_initial(initial) do
    [[string]] = Regex.scan(~r/initial state: (.*)/, initial, capture: :all_but_first)

    # Create a List of the index of the "#"
    string
    |> to_charlist()
    |> Enum.with_index()
    |> Enum.reject(&(elem(&1, 0) == ?.))
    |> Enum.map(&elem(&1, 1))
  end

  # Converts a list of 0 and 1 to a number assuming a binary representation.
  # Attention, the binary is in the reverse order than the typical writing (unit is the first element of the list)
  def to_number(l) do
    Enum.reduce(l, {1, 0}, fn e, {c_mul, c_sum} -> {c_mul * 2, c_sum + c_mul * e} end) |> elem(1)
  end

  # A rule is a tuple {value of the rule => 0 or 1}
  def parse_rule(rule) do
    Regex.scan(~r/(.)(.)(.)(.)(.) => (.)/, rule, capture: :all_but_first)
    |> hd()
    |> Enum.map(fn s -> hd(String.to_charlist(s)) end)
    |> Enum.map(&if &1 == ?., do: 0, else: 1)
    |> Enum.split(5)
    |> then(fn {i, t} -> {to_number(i), hd(t)} end)
  end

  # Rules is a Map {value of the rule => 0 or 1}
  def parse_rules(rules),
    do: rules |> String.split("\n", trim: true) |> Enum.map(&parse_rule/1) |> Map.new()

  # Returns {pots, rules}
  # pots is a List of the indexes of the pots with plants
  # rules is a Map of {value of the rule => 0 or 1}
  # value of the rule is the value of the binary sequence representing the rule. For example [1,0,0,1,0] represents 1 + 0 * 2 + 0 * 4 + 1 * 8 + 0 * 16
  def parse(args) do
    [initial, rest] = String.split(args, "\n\n", trim: true)
    {parse_initial(initial), parse_rules(rest)}
  end

  # Given a pot index, and a MapSet of pots with plant returns the list of surrounding pots with their content (0 = no plant, 1 = plant) and translates it into a number
  def pots_around(pots, pot) do
    for p <- (pot - 2)..(pot + 2) do
      if p in pots, do: 1, else: 0
    end
    |> to_number()
  end

  # Compute a next generation
  def compute_next({pots, rules}) do
    {min_pot, max_pot} = Enum.min_max(pots)
    # Loop from min index to max index with 2 additional index on the left and 2 on the right
    new_pots =
      Enum.reduce((min_pot - 2)..(max_pot + 2), [], fn p, acc ->
        # Compute the value of the pots around and apply the rule. If no rule applies, assume that no plant would grow
        # If a plant grows in the next generation, add it to the accumulator
        if Map.get(rules, pots_around(pots, p), 0) == 0, do: acc, else: [p | acc]
      end)

    # Return a tuple so that iterating is more convenient
    {new_pots, rules}
  end

  # Compute the value of a generation
  def value({pots, _}), do: Enum.sum(pots)

  def part1(args) do
    # Iterate 20 times
    Enum.reduce(1..20, parse(args), fn _, acc -> compute_next(acc) end) |> value()
  end

  def part2(args) do
    # We notice that after some iteration, the increase rate is stable

    # Move forward
    jump = 150
    after_jump = Enum.reduce(1..jump, parse(args), fn _, acc -> compute_next(acc) end)
    # Then do one step
    one_step = compute_next(after_jump)
    # Compute the increase representing one step
    delta = value(one_step) - value(after_jump)
    # Extrapolate linearly
    value(after_jump) + delta * (@target - jump)
  end
end
