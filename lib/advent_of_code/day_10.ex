defmodule AdventOfCode.Day10 do
  def parse_line(line) do
    Regex.scan(~r/position=<(.+),(.+)> velocity=<(.+),(.+)>/, line, capture: :all_but_first)
    |> hd()
    |> Enum.map(fn x -> x |> String.trim() |> String.to_integer() end)
  end

  def parse(args), do: args |> String.split("\n", trim: true) |> Enum.map(&parse_line/1)

  def get_x(stars), do: Enum.map(stars, &elem(&1, 0))
  def get_y(stars), do: Enum.map(stars, &elem(&1, 1))

  def print(stars) do
    {x_min, x_max} = stars |> get_x |> Enum.min_max()
    {y_min, y_max} = stars |> get_y |> Enum.min_max()

    for y <- y_min..y_max do
      for x <- x_min..x_max do
        if {x, y} in stars, do: "*", else: " "
      end
      |> Enum.join()
      |> IO.puts()
    end
  end

  # Count the total of distinct y's in the list
  def dispers(stars) do
    {y_min, y_max} = stars |> get_y |> Enum.min_max()
    y_max - y_min
  end

  # Compute the star positions at time t
  def at_time(starvec, t) do
    for [x, y, vx, vy] <- starvec, do: {x + t * vx, y + t * vy}
  end

  def part1(args) do
    starvec = args |> parse()

    # Iterate until the y's dispersion <= 10
    [target_t] =
      Stream.iterate(0, &(&1 + 1))
      |> Stream.filter(fn t -> dispers(at_time(starvec, t)) <= 10 end)
      |> Enum.take(1)

    IO.puts("Message appears at time #{target_t}")
    print(at_time(starvec, target_t))
  end

  def part2(args), do: part1(args)
end
