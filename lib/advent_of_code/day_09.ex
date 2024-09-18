defmodule AdventOfCode.Day09 do
  def parse(args) do
    [[_, a, b]] = Regex.scan(~r/(\d+) players; last marble is worth (\d+) points/, args)
    {String.to_integer(a), String.to_integer(b)}
  end

  # The Ring is modeled as a Map. Each marble knows the previous and next marble in the ring
  # { %{a_marble => {previous_marble, next_marble}}, current_marble}
  #

  # Initial Ring
  def new_ring(), do: {%{0 => {0, 0}}, 0}

  def move_clockwise(ring, current_marble), do: ring[current_marble] |> elem(1)

  # Counter clockwise
  def move_cclockwise(ring, current_marble), do: ring[current_marble] |> elem(0)

  def move_cclockwise(ring, current_marble, n) do
    Enum.reduce(1..n, current_marble, fn _, m -> move_cclockwise(ring, m) end)
  end

  # Case where the marble is a multiple of 23
  def put({ring, current_marble}, marble) when rem(marble, 23) == 0 do
    # Find the marble 7 steps counter clockwise
    m7_marble = move_cclockwise(ring, current_marble, 7)
    # Identify its neighbors
    {p_marble, n_marble} = ring[m7_marble]
    # Store the previous marble on the left and the next marble of the right
    {p_marble_previous, _} = ring[p_marble]
    {_, n_marble_next} = ring[n_marble]
    # Remove the m7_marble
    new_ring =
      ring
      |> Map.put(p_marble, {p_marble_previous, n_marble})
      |> Map.put(n_marble, {p_marble, n_marble_next})
      |> Map.delete(m7_marble)

    # Increase the score
    {{new_ring, n_marble}, marble + m7_marble}
  end

  # Dealing with the initial case
  def put({%{0 => {0, 0}}, 0}, 1) do
    {{%{0 => {1, 1}, 1 => {0, 0}}, 1}, 0}
  end

  # Standard case
  def put({ring, current_marble}, marble) do
    # Identify the 2 next marbles clockwise
    p1_marble = move_clockwise(ring, current_marble)
    p2_marble = move_clockwise(ring, p1_marble)

    # Insert marble
    new_ring =
      ring
      |> Map.put(p1_marble, {current_marble, marble})
      |> Map.put(marble, {p1_marble, p2_marble})
      |> Map.put(p2_marble, {marble, ring[p2_marble] |> elem(1)})

    {{new_ring, marble}, 0}
  end

  # Main game loop
  def play({n_players, last_marble}) do
    # Initialize the players' score
    initial_scores = for p <- 0..(n_players - 1), into: %{}, do: {p, 0}

    Enum.reduce(
      1..last_marble,
      # {ring  state, current player id, scores}
      {new_ring(), 0, initial_scores},
      fn m, {r, p, scores} ->
        # Put a marble in the ring
        {new_r, score} = put(r, m)
        # Update scores if necessary
        if score == 0,
          do: {new_r, rem(p + 1, n_players), scores},
          else: {new_r, rem(p + 1, n_players), Map.update!(scores, p, fn s -> s + score end)}
      end
    )
    # Find the maximum score
    |> elem(2)
    |> Map.values()
    |> Enum.max()
  end

  def part1(args), do: args |> parse() |> play()

  def part2(args) do
    {p, m} = args |> parse()
    play({p, m * 100})
  end
end
