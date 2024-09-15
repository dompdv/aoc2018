defmodule AdventOfCode.Day07 do
  @regex ~r/Step ([A-Z]+) must be finished before step ([A-Z]+) can begin./

  ### Parsing
  def parse_line(line) do
    Regex.scan(@regex, line, capture: :all_but_first)
    |> List.flatten()
    |> Enum.map(&hd(to_charlist(&1)))
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

  # Given the state of "on" steps, identify the next steps that could be started
  # "state" is a list of finished steps
  # predecessors is the list of {step, list of steps that should be finished before}.
  # predecessors is ordered alphabetically
  def fire(state, predecessors) do
    m_state = MapSet.new(state)

    Enum.reduce(predecessors, [], fn {step, pred_of_step}, acc ->
      # jump over steps that are already finished
      # if all the required steps are already on, then we have found the next step
      if step not in state and MapSet.subset?(MapSet.new(pred_of_step), m_state),
        do: [step | acc],
        else: acc
    end)
    |> Enum.reverse()
  end

  def part1(args) do
    predecessors = args |> parse() |> predecessors()

    # Repeatidely find the next step to "fire"
    # We know that there will be as many "fire" event that we have in the predecessors list
    Enum.reduce(1..length(predecessors), [], fn _, acc -> [hd(fire(acc, predecessors)) | acc] end)
    |> Enum.reverse()
    |> to_string()
  end

  def worker_actions(minute, steps, ws) do
    {new_steps, new_workers_state} =
      Enum.reduce(
        ws,
        {steps, []},
        fn
          {_, :idle} = w, {s, acc_ws} ->
            {s, [w | acc_ws]}

          {_, {till_minute, _}} = w, {s, acc_ws} when minute < till_minute ->
            {s, [w | acc_ws]}

          {w, {_, what}}, {s, acc_ws} ->
            {[what | s], [{w, :idle} | acc_ws]}
        end
      )

    {new_steps, new_workers_state |> Enum.reverse()}
  end

  def part2(args) do
    predecessors = args |> parse() |> predecessors()
    result_length = length(predecessors)
    workers_state = for w <- 1..5, do: {w, :idle}

    Stream.iterate(0, &(&1 + 1))
    |> Enum.reduce_while(
      {[], workers_state},
      fn minute, {fired_steps, c_ws} ->
        {new_fired_steps, new_c_ws} =
          worker_actions(minute, fired_steps, c_ws)

        if length(new_fired_steps) == result_length do
          {:halt, {minute, Enum.reverse(new_fired_steps)}}
        else
          next_steps = fire(new_fired_steps, predecessors)
          in_process = for {_, {_, step}} <- new_c_ws, do: step
          next_steps = next_steps |> Enum.reject(fn s -> s in in_process end)

          idle_workers = for {w, :idle} <- new_c_ws, do: w

          starting_workers =
            for {w, step} <- Enum.zip(idle_workers, next_steps),
                into: %{},
                do: {w, {minute + step - 4, step}}

          final_c_ws =
            for {w, ws} <- new_c_ws do
              if Map.has_key?(starting_workers, w), do: {w, starting_workers[w]}, else: {w, ws}
            end

          {:cont, {new_fired_steps, final_c_ws}}
        end
      end
    )
    |> elem(0)
  end
end
