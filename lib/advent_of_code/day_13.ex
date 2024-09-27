defmodule AdventOfCode.Day13 do
  # The fundamental data structure is:
  # For the tracks:
  #    a map %{{x,y} => a cell description}. Only occupied cells are in the map.
  #    Cell description    | -> :v, - -> :h, / -> :sl, \ -> :bsl, + -> :cross
  # For the carts:
  #     a list of carts. Each cart is a tuple: {{x,y}, facing direction, where to go at the next crossing}
  #     facing directions are :n, :e, :s, :w
  #     next crossing direction is :left, :straight, :right

  def parse_line({line, y}) do
    line
    |> String.to_charlist()
    |> Enum.with_index()
    |> Enum.reduce({[], []}, fn {c, x}, {tracks, carts} ->
      case c do
        ?| -> {[{{x, y}, :v} | tracks], carts}
        ?- -> {[{{x, y}, :h} | tracks], carts}
        ?/ -> {[{{x, y}, :sl} | tracks], carts}
        ?\\ -> {[{{x, y}, :bsl} | tracks], carts}
        ?+ -> {[{{x, y}, :cross} | tracks], carts}
        ?> -> {[{{x, y}, :h} | tracks], [{{x, y}, :e, :left} | carts]}
        ?< -> {[{{x, y}, :h} | tracks], [{{x, y}, :w, :left} | carts]}
        ?^ -> {[{{x, y}, :v} | tracks], [{{x, y}, :n, :left} | carts]}
        ?v -> {[{{x, y}, :v} | tracks], [{{x, y}, :s, :left} | carts]}
        _ -> {tracks, carts}
      end
    end)
  end

  # returns {tracks, carts} (see start of the module above)
  def parse(args) do
    {tracks, carts} =
      args
      |> String.split("\n", trim: true)
      |> Enum.with_index()
      |> Enum.map(&parse_line/1)
      |> Enum.unzip()

    {tracks |> List.flatten() |> Map.new(), carts |> List.flatten()}
  end

  # Define directions in terms of dx and dy
  @deltas %{n: {0, -1}, e: {1, 0}, s: {0, 1}, w: {-1, 0}}
  # Turn left and right
  @left %{n: :w, w: :s, s: :e, e: :n}
  @right %{n: :e, e: :s, s: :w, w: :n}
  # outcome of meeting a / or \
  @boing %{
    {:sl, :n} => :e,
    {:sl, :e} => :n,
    {:sl, :w} => :s,
    {:sl, :s} => :w,
    {:bsl, :s} => :e,
    {:bsl, :e} => :s,
    {:bsl, :w} => :n,
    {:bsl, :n} => :w
  }
  # New direction when turning left, right or going straight
  def cross(facing, :left), do: {@left[facing], :straight}
  def cross(facing, :right), do: {@right[facing], :left}
  def cross(facing, :straight), do: {facing, :right}

  # Move one cart
  def move_one_cart(cart, tracks) do
    # Compute new position
    {{x, y}, facing, direction} = cart
    {dx, dy} = @deltas[facing]
    new_pos = {x + dx, y + dy}
    cell = tracks[new_pos]

    # Adjust the new direction according to what in the cell of the new position.
    # Adjust also the next direction to go when entering a :cross
    cond do
      # | or - : no turn
      cell in [:v, :h] ->
        {new_pos, facing, direction}

      # + : update facing and next direction
      cell == :cross ->
        {new_direction, new_next} = cross(facing, direction)
        {new_pos, new_direction, new_next}

      # \ or / : update facing direction
      true ->
        {new_pos, @boing[{cell, facing}], direction}
    end
  end

  # Collision of a cart with one of a list of carts ?
  def collide?({pos, _, _}, carts) do
    Enum.find(carts, fn {s_pos, _, _} -> pos == s_pos end)
  end

  # Part 1 : Move till a crash is detected

  # Process all carts (one turn)
  # def process_carts_stop_when_crashing(list of carts to move, list of carts already processed, tracks)

  # end of recursion
  def process_carts_stop_when_crashing([], acc_carts, _), do: acc_carts

  # Move one cart
  def process_carts_stop_when_crashing([cart | rest_cart], acc_carts, tracks) do
    new_cart = move_one_cart(cart, tracks)

    # Stop if collision, otherwise process the next cart
    if collide?(new_cart, rest_cart ++ acc_carts) == nil,
      do: process_carts_stop_when_crashing(rest_cart, [new_cart | acc_carts], tracks),
      else: {:crash, new_cart}
  end

  # Start to process one turn
  def process_carts_stop_when_crashing(carts, tracks) do
    # Ensure to process carts in the right order
    carts
    |> Enum.sort(fn {{x1, y1}, _, _}, {{x2, y2}, _, _} -> {y1, x1} <= {y2, x2} end)
    |> process_carts_stop_when_crashing([], tracks)
  end

  def part1(args) do
    {tracks, carts} = args |> parse()

    # compute each turn till a crash
    Stream.iterate(0, &(&1 + 1))
    |> Enum.reduce_while(carts, fn _, c_carts ->
      case process_carts_stop_when_crashing(c_carts, tracks) do
        {:crash, {pos, _, _}} -> {:halt, pos}
        new_carts -> {:cont, new_carts}
      end
    end)
    |> then(fn {x, y} -> "#{x},#{y}" end)
  end

  # Part 2: remove carts when they collide
  def move_highlander([], acc_carts, _), do: acc_carts

  def move_highlander([cart | rest_cart], acc_carts, tracks) do
    new_cart = move_one_cart(cart, tracks)

    case collide?(new_cart, rest_cart ++ acc_carts) do
      nil ->
        move_highlander(rest_cart, [new_cart | acc_carts], tracks)

      {other_cart_pos, _, _} ->
        # remove the carts from the list of carts to process or the carts alreay processed, and discard the current one
        new_acc_carts = Enum.reject(acc_carts, fn {pos, _, _} -> pos == other_cart_pos end)
        new_rest_carts = Enum.reject(rest_cart, fn {pos, _, _} -> pos == other_cart_pos end)
        move_highlander(new_rest_carts, new_acc_carts, tracks)
    end
  end

  def move_highlander(carts, tracks) do
    # Ensure the right order
    carts
    |> Enum.sort(fn {{x1, y1}, _, _}, {{x2, y2}, _, _} -> {y1, x1} <= {y2, x2} end)
    |> move_highlander([], tracks)
  end

  def part2(args) do
    {tracks, carts} = args |> parse()

    Stream.iterate(0, &(&1 + 1))
    |> Enum.reduce_while(carts, fn _, c_carts ->
      new_carts = move_highlander(c_carts, tracks)
      # Stop if there is only one cart left
      if length(new_carts) == 1, do: {:halt, elem(hd(new_carts), 0)}, else: {:cont, new_carts}
    end)
    |> then(fn {x, y} -> "#{x},#{y}" end)
  end
end
