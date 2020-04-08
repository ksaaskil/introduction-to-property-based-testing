defmodule TPBTVariationsTest do
  use ExUnit.Case
  use PropCheck, default_opts: [numtests: 100, search_steps: 100]
  doctest Pbt

  def path() do
    list(oneof([:left, :right, :up, :down]))
  end

  # User-defined neighbor function that adds more
  # steps right and down than up and left.
  # All paths are variations of the first path drawn from the path() generator.
  def path_next() do
    fn prev_path, {_depth, _temperature} ->
      # IO.puts("Temperature #{temperature}, depth: #{depth}")
      # IO.puts("Temperature #{temperature}")
      let(
        next_steps <-
          list(
            frequency([
              {1, oneof([:up, :left])},
              {2, oneof([:right, :down])}
            ])
          ),
        do: prev_path ++ next_steps
      )
    end
  end

  property "targeted path generation with variation", search_steps: 10, numtests: 5 do
    forall p <- path() do
      p_gen = let(p_ <- p, do: p_)

      forall_targeted p2 <- user_nf(p_gen, path_next()) do
        IO.puts("Path has #{length(p2)} steps: #{Enum.join(p2, ",")}")
        {x, y} = List.foldl(p2, {0, 0}, fn v, acc -> move(v, acc) end)
        neg_loss = x - y
        IO.puts("Last point: {#{x}, #{y}}, negative loss: #{neg_loss}")
        # Prefer paths leading to lower right
        maximize(neg_loss)
        true
      end
    end
  end

  # Helpers
  def move(:left, {x, y}), do: {x - 1, y}
  def move(:right, {x, y}), do: {x + 1, y}
  def move(:up, {x, y}), do: {x, y + 1}
  def move(:down, {x, y}), do: {x, y - 1}
end
