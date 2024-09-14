defmodule AdventOfCode.Day07 do
  @regex ~r/Step ([A-Z]+) must be finished before step ([A-Z]+) can begin./

  ### Parsing
  def parse_line(line) do
    Regex.scan(@regex, line, capture: :all_but_first)
    |> List.flatten()
    |> to_charlist()
  end

  def parse(args) do
    args
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  # "Predecessors" is the alphabetically ordered list of {step, list of steps that should be "on" before triggering it}.
  def predecessors(rules) do
    # Find the steps mentioned in the rules
    steps = rules |> List.flatten() |> Enum.uniq()

    # Make sure that steps without previous state appears
    for(l <- steps, into: %{}, do: {l, []})
    # The trick is to group by the second step and associate the list all their first steps
    |> Map.merge(rules |> Enum.group_by(fn [_a, b] -> b end, fn [a, _b] -> a end))
    # Sort by alphabetical order
    |> Enum.sort_by(&elem(&1, 0))
  end

  # Given the state of "on" steps, identify the next step that will turn to "on"
  # state is a set of the "on" steps, like MapSet.new([?A, ?C])
  # predecessors is the list of {step, set of steps that should be "on" before}.
  # predecessors is ordered alphabetically
  def fire(state, predecessors) do
    m_state = MapSet.new(state)

    Enum.reduce_while(
      # go through the list of predecessors in alphabetical order
      predecessors,
      # no need for an acc in this reduce_while
      nil,
      fn {step, pred_of_step}, _ ->
        # jump over steps that are already "on"
        # if all the required steps are already on, then we have found the next step
        if step not in state and MapSet.subset?(MapSet.new(pred_of_step), m_state),
          do: {:halt, step},
          else: {:cont, nil}
      end
    )
  end

  def part1(args) do
    predecessors = args |> parse() |> predecessors()

    # Repeatidely find the next step to "fire"
    # We know that there will be as many "fire" event that we have in the predecessors list
    # accumulation of the fired steps in the reverse order

    Enum.reduce(1..length(predecessors), [], fn _, acc -> [fire(acc, predecessors) | acc] end)
    |> Enum.reverse()
    |> to_string()
  end

  def part2(args) do
    args |> test() |> parse() |> predecessors()
  end

  def test(_) do
    """
    Step C must be finished before step A can begin.
    Step C must be finished before step F can begin.
    Step A must be finished before step B can begin.
    Step A must be finished before step D can begin.
    Step B must be finished before step E can begin.
    Step D must be finished before step E can begin.
    Step F must be finished before step E can begin.
    """
  end
end
