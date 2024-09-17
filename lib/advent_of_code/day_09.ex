defmodule AdventOfCode.Day09 do
  def parse(args) do
    [[_, a, b]] = Regex.scan(~r/(\d+) players; last marble is worth (\d+) points/, args)
    {String.to_integer(a), String.to_integer(b)}
  end

  def put({ring, ring_size, current_marble}, marble) when rem(marble, 23) == 0 do
    where =
      if current_marble - 7 < 0, do: current_marble - 7 + ring_size, else: current_marble - 7

    {left, [removed | right]} = Enum.split(ring, where)
    {{left ++ right, ring_size - 1, where}, removed + marble}
  end

  def put({ring, ring_size, current_marble}, marble) do
    case rem(current_marble + 2, ring_size) do
      0 ->
        {{ring ++ [marble], ring_size + 1, ring_size}, 0}

      n ->
        {left, right} = Enum.split(ring, n)
        {{left ++ [marble] ++ right, ring_size + 1, n}, 0}
    end
  end

  def part1(args) do
    {n_players, last_marble} = args |> parse()
    ring = [0]
    ring_size = length(ring)
    current_marble = 0

    initial_scores = for p <- 0..(n_players - 1), into: %{}, do: {p, 0}

    Enum.reduce(
      1..last_marble,
      {{ring, ring_size, current_marble}, 0, initial_scores},
      fn m, {r, p, scores} ->
        {new_r, score} = put(r, m)

        if score == 0,
          do: {new_r, rem(p + 1, n_players), scores},
          else: {new_r, rem(p + 1, n_players), Map.update!(scores, p, fn s -> s + score end)}
      end
    )
    |> elem(2)
    |> Map.values()
    |> Enum.max()
  end

  def part2(args) do
    {n_players, last_marble} = args |> parse()
    last_marble = (last_marble * 100) |> IO.inspect()
    ring = [0]
    ring_size = length(ring)
    current_marble = 0

    initial_scores = for p <- 0..(n_players - 1), into: %{}, do: {p, 0}

    Enum.reduce(
      1..last_marble,
      {{ring, ring_size, current_marble}, 0, initial_scores},
      fn m, {r, p, scores} ->
        if rem(m, 10000) == 0, do: IO.inspect(m)
        {new_r, score} = put(r, m)

        if score == 0,
          do: {new_r, rem(p + 1, n_players), scores},
          else: {new_r, rem(p + 1, n_players), Map.update!(scores, p, fn s -> s + score end)}
      end
    )
    |> elem(2)
    |> Map.values()
    |> Enum.max()
  end
end
