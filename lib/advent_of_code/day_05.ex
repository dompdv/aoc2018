defmodule AdventOfCode.Day05 do
  # Initiate recursion
  def react(chain), do: react(chain, [])

  # If we reach the end, no reaction was observed, so return false
  def react([], acc), do: {false, Enum.reverse(acc)}

  # There is a reaction, stop, return true and the chain after reaction
  def react([a, b | r], acc) when a == b + 32 or b == a + 32,
    do: {true, Enum.reverse(acc) ++ r}

  def react([a | r], acc), do: react(r, [a | acc])

  def reduce(chain) do
    # React
    case react(chain) do
      # Loop if a reaction was observed
      {true, rest} -> reduce(rest)
      # Finish otherwise
      {false, rest} -> rest
    end
  end

  def part1(args) do
    args |> String.trim() |> String.to_charlist() |> reduce() |> length()
  end

  def part2(args) do
    input = args |> String.trim() |> String.to_charlist()
    # List of the polymers
    polymers = input |> Enum.uniq() |> Enum.reject(&(&1 > ?Z))

    # Loop on each polymer
    for polymer <- polymers do
      # Remove a polymer and reduce
      input |> Enum.reject(&(&1 == polymer or &1 == polymer + 32)) |> reduce() |> length()
    end
    # Take the minimum
    |> Enum.min()
  end
end
