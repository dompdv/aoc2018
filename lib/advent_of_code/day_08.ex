defmodule AdventOfCode.Day08 do
  def parse(args),
    do: args |> String.trim() |> String.split(" ", trim: true) |> Enum.map(&String.to_integer/1)

  # A tree is represented by a root node %{meta: [list of metadata], children: [list of children nodes]}
  def build_tree(description), do: build_node(description) |> elem(1)

  def build_node([qchildren, qmetadata | r]) do
    # "r" is the remainder of the list after processing
    # Attention: "r" is rebound several times

    # Build the list of children
    {r, children} =
      if qchildren == 0 do
        {r, []}
      else
        Enum.reduce(1..qchildren, {r, []}, fn _, {rest, nodes} ->
          {new_rest, a_node} = build_node(rest)
          {new_rest, [a_node | nodes]}
        end)
      end

    # Collect metadata
    {metadata, r} = Enum.split(r, qmetadata)
    # Build node
    {r, %{meta: metadata, children: Enum.reverse(children)}}
  end

  # No comment, it's exactly as written in on AoC
  def add_metadata(%{meta: meta, children: children}) do
    Enum.sum(meta) + Enum.sum(for c <- children, do: add_metadata(c))
  end

  def value_node(%{meta: meta, children: []}), do: Enum.sum(meta)

  def value_node(%{meta: meta, children: children}) do
    for m <- meta do
      cond do
        m == 0 -> 0
        m > length(children) -> 0
        true -> value_node(Enum.at(children, m - 1))
      end
    end
    |> Enum.sum()
  end

  def part1(args), do: args |> parse() |> build_tree() |> add_metadata()

  def part2(args), do: args |> parse() |> build_tree() |> value_node()
end
