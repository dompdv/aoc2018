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

  # At the start of a minute, we execute worker actions
  # this means that we mark as "done" the steps which are finished (when the current minute reaches the expected time of the end of the task)
  # otherwise, do nothing
  # the worker states (ws) and the "achieved steps" state are updated
  def execute_worker_actions(current_time, steps, ws) do
    {new_steps, new_workers_state} =
      Enum.reduce(ws, {steps, []}, fn
        # Do nothing if a worker is idle
        {_, :idle} = w, {s, acc_ws} ->
          {s, [w | acc_ws]}

        # Do nothing if we have not achieved the step
        {_, {till_time, _}} = w, {s, acc_ws} when current_time < till_time ->
          {s, [w | acc_ws]}

        # mark step as finished and put back the worker in :idle mode
        {w, {_, what}}, {s, acc_ws} ->
          {[what | s], [{w, :idle} | acc_ws]}
      end)

    {new_steps, new_workers_state |> Enum.reverse()}
  end

  def part2(args) do
    # Compute predecessors
    predecessors = args |> parse() |> predecessors()
    result_length = length(predecessors)
    # the state of workers is a ordered list [{worker number, worker state}]
    # a worker state is either
    # - :idle => the worker does nothing and ready to start to work on a step
    # - {till_minute, step} => the worker will work on "step" till the "till_time" time
    # Workers are in idle mode at first
    initial_workers_state = for w <- 1..5, do: {w, :idle}
    initial_finished_steps = []

    # Clock is ticking till we process all steps
    Stream.iterate(0, &(&1 + 1))
    |> Enum.reduce_while(
      {initial_finished_steps, initial_workers_state},
      fn current_time, {finished_steps, workers_state} ->
        # Execute potential actions by the workers, update finished_steps if necessary
        {finished_steps, workers_state} =
          execute_worker_actions(current_time, finished_steps, workers_state)

        # If we have executed all steps, then stop and return the time
        if length(finished_steps) == result_length do
          {:halt, current_time}
        else
          # What are the potential next_steps ?
          potentiaL_next_steps = fire(finished_steps, predecessors)
          # And the steps that a worker is working on
          in_process_steps = for {_, {_, step}} <- workers_state, do: step
          # The real next steps are the potential minus the "in process" steps
          next_steps = Enum.reject(potentiaL_next_steps, fn s -> s in in_process_steps end)
          # Distribute the next_steps on the idle workers
          # When we attribute a task to a worker, his state becomes {time of the end of the task, step on which they work}
          idle_workers = for {w, :idle} <- workers_state, do: w

          starting_workers =
            for {w, step} <- Enum.zip(idle_workers, next_steps),
                into: %{},
                do: {w, {current_time + step - 4, step}}

          # update the workers_state for the workers that have been attributed a new task
          final_workers_state =
            for {w, ws} <- workers_state do
              if Map.has_key?(starting_workers, w), do: {w, starting_workers[w]}, else: {w, ws}
            end

          {:cont, {finished_steps, final_workers_state}}
        end
      end
    )
  end
end
