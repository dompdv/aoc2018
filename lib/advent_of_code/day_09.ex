defmodule AdventOfCode.Day09 do
  def parse(args) do
    [[_, a, b]] = Regex.scan(~r/(\d+) players; last marble is worth (\d+) points/, args)
    {String.to_integer(a), String.to_integer(b)}
  end

  def put({ring, ring_size, current_marble}, marble) when rem(marble, 23) == 0 do
    n =
      if current_marble - 7 < 0, do: current_marble - 7 + ring_size, else: current_marble - 7

    left = binary_part(ring, 0, n * 4)
    <<removed::big-unsigned-integer-size(32)>> = binary_part(ring, n * 4, 4)
    right = binary_slice(ring, (n * 4 + 4)..-1//1)
    {{left <> right, ring_size - 1, n}, removed + marble}
  end

  def put({ring, ring_size, current_marble}, marble) do
    case rem(current_marble + 2, ring_size) do
      0 ->
        {{ring <> <<marble::unsigned-big-integer-size(32)>>, ring_size + 1, ring_size}, 0}

      n ->
        left = binary_part(ring, 0, n * 4)
        right = binary_slice(ring, (n * 4)..-1//1)
        {{left <> <<marble::unsigned-big-integer-size(32)>> <> right, ring_size + 1, n}, 0}
    end
  end

  def new_ring(), do: {<<0::unsigned-big-integer-size(32)>>, 1, 0}

  def play({n_players, last_marble}) do
    initial_scores = for p <- 0..(n_players - 1), into: %{}, do: {p, 0}

    Enum.reduce(
      1..last_marble,
      {new_ring(), 0, initial_scores},
      fn m, {r, p, scores} ->
        if rem(m, 1000) == 0, do: IO.inspect(m)

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

  def part1(args), do: args |> parse() |> play()

  def part2(args) do
    {p, m} = args |> parse()
    play({p, m * 100})
  end
end
