defmodule AdventOfCode.Day10 do
  def parse_line(line) do
    Regex.scan(~r/position=<(.+),(.+)> velocity=<(.+),(.+)>/, line, capture: :all_but_first)
    |> hd()
    |> Enum.map(fn x -> x |> String.trim() |> String.to_integer() end)
  end

  def parse(args), do: args |> String.split("\n", trim: true) |> Enum.map(&parse_line/1)

  def get_x(stars) do
    for {x, _} <- stars, do: x
  end

  def get_y(stars) do
    for {_, y} <- stars, do: y
  end

  def print(stars) do
    {x_min, x_max} = stars |> get_x |> Enum.min_max()
    {y_min, y_max} = stars |> get_y |> Enum.min_max()

    if x_max - x_min > 300 or y_min - y_min > 30 do
      "Too big"
    else
      stars = MapSet.new(stars)

      for y <- y_min..y_max do
        for x <- x_min..x_max do
          if {x, y} in stars, do: "*", else: " "
        end
        |> Enum.join()
        |> IO.puts()
      end
    end

    nil
  end

  # Measures the total of distinct x's and y's in the list
  def dispers(stars) do
    dispers_x = stars |> get_x() |> Enum.uniq() |> length()
    dispers_y = stars |> get_y() |> Enum.uniq() |> length()

    dispers_x + dispers_y
  end

  # Compute the star positions at time t
  def at_time(starvec, t) do
    for [x, y, vx, vy] <- starvec, do: {x + t * vx, y + t * vy}
  end

  def part1(args) do
    starvec = args |> parse()

    # Find the time of minimal dispersion of x's and y's
    {target_t, _} =
      for t <- 1..12000 do
        {t, starvec |> at_time(t) |> dispers()}
      end
      |> Enum.min_by(&elem(&1, 1))

    # This is when the message appears
    IO.puts("Message appears at time #{target_t}")
    starvec |> at_time(target_t) |> print()
  end

  def part2(args), do: part1(args)
end
