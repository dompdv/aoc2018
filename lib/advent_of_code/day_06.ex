defmodule AdventOfCode.Day06 do
  @big_int 100_000_000_000
  def parse_line(line) do
    line
    |> String.split(",", trim: true)
    |> Enum.map(&(&1 |> String.trim() |> String.to_integer()))
    |> List.to_tuple()
  end

  def parse(args), do: args |> String.split("\n", trim: true) |> Enum.map(&parse_line/1)

  #  Calculates the Manhattan distance between two points in a 2D plane.
  def manhattan({x1, y1}, {x2, y2}), do: abs(x1 - x2) + abs(y1 - y2)

  # Get a circle in manhattan distance
  def get_circle(p, 0), do: [p]

  def get_circle({rx, ry}, r) do
    top_down_row = for x <- (rx - r)..(rx + r), do: [{x, ry - r}, {x, ry + r}]
    left_right_col = for y <- (ry - r + 1)..(ry + r - 1), do: [{rx - r, y}, {rx + r, y}]
    (top_down_row ++ left_right_col) |> List.flatten()
  end

  # Find the closest "place" of a location named "to"
  # returns nil if there are several places at the minimal distance
  def closest(places, to) do
    # Go through all the Places
    {_, place, type} =
      Enum.reduce(
        places,
        # {current minimal distance, Place related to the minimal distance, :ex_aequo or :alone}
        {@big_int, nil, false},
        fn p, {min_dist, _, _} = acc ->
          dist = manhattan(p, to)

          cond do
            dist > min_dist -> acc
            dist < min_dist -> {dist, p, :single}
            dist == min_dist -> {dist, p, :ex_aequo}
          end
        end
      )

    if type == :ex_aequo, do: nil, else: place
  end

  def part1(args) do
    places = args |> parse()
    # Find the enclosing rectangle (smallest rectangle that includes all the places)
    {x0, x1} = places |> Enum.map(&elem(&1, 0)) |> Enum.min_max()
    {y0, y1} = places |> Enum.map(&elem(&1, 1)) |> Enum.min_max()
    # Find the enclosing circle, which is immediately around the enclosing rectangle
    top_down_row = for x <- (x0 - 1)..(x1 + 1), do: [{x, y0 - 1}, {x, y1 + 1}]
    left_right_col = for y <- y0..y1, do: [{x0 - 1, y}, {x1 + 1, y}]
    enclosing_circle = (top_down_row ++ left_right_col) |> List.flatten()

    # The trick is that the places (Letters) that are the closest of the locations in the enclosing circles
    # are in fact linked to infinite area. So we'll be able to rule them out below
    infinites_places =
      for(p <- enclosing_circle, do: closest(places, p)) |> MapSet.new() |> MapSet.delete(nil)

    # Go through all locations in the enclosing rectangle and identify the closest Place
    for(x <- x0..x1, y <- y0..y1, do: closest(places, {x, y}))
    # Do not consider "equally distant locations" and the Places linked to infinite places
    |> Enum.filter(&(&1 != nil and &1 not in infinites_places))
    # Find the Place with maximum occurence
    |> Enum.frequencies()
    |> Map.values()
    |> Enum.max()
  end

  def part2(args) do
    threshold = 10000
    places = args |> parse()
    {x0, x1} = places |> Enum.map(&elem(&1, 0)) |> Enum.min_max()
    {y0, y1} = places |> Enum.map(&elem(&1, 1)) |> Enum.min_max()
    mid_p = {div(x0 + x1, 2), div(y0 + y1, 2)}

    # The strategy is to start from the middle of the places and to test the locations in a concentric fashion.
    # We start by the middle point, then the 8 square at a distance 1 (manhattan), then the 16 at distance 2, etc (a "circle" is a square with a manhattan distance)
    # Along the way, we count the locations that are candidates (total distance below the threshold)
    # We stop when all location on a single circle are outside of the area because we know that larger circles are outside the area
    Enum.reduce_while(
      # increment r = radius of the circle
      Stream.iterate(0, &(&1 + 1)),
      # Count of locations in the target area
      0,
      # global_count = count of locations in the area
      fn r, global_count ->
        # Iterate on the location on a circle
        candidates_in_circle =
          Enum.reduce(
            get_circle(mid_p, r),
            0,
            fn p, local_count ->
              # Compute the total distances from the considered location
              total_dist = places |> Enum.map(&manhattan(&1, p)) |> Enum.sum()
              # Increment if < thresshold
              if total_dist < threshold, do: local_count + 1, else: local_count
            end
          )

        # If there are no locations in the target area on the circle, we can stop
        if candidates_in_circle == 0,
          do: {:halt, global_count},
          else: {:cont, global_count + candidates_in_circle}
      end
    )
  end
end
