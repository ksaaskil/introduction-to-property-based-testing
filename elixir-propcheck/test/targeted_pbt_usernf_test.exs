defmodule TargetedPbtUsernfTest do
  use ExUnit.Case
  use PropCheck, default_opts: [numtests: 100, search_steps: 100]
  doctest Pbt

  def path() do
    list(oneof([:left, :right, :up, :down]))
  end

  # User-defined neighbor function that adds
  # steps right and down in the previous path.
  # All paths are variations of the first path drawn from the path() generator.
  def path_next() do
    fn prev_path, _temperature ->
      let(
        next_steps <- list(oneof([:right, :down])),
        do: prev_path ++ next_steps
      )
    end
  end

  property "targeted path generation" do
    forall_targeted p <- user_nf(path(), path_next()) do
      IO.puts("Path has #{length(p)} steps: #{Enum.join(p, ",")}")
      {x, y} = List.foldl(p, {0, 0}, fn v, acc -> move(v, acc) end)
      neg_loss = x - y
      IO.puts("Last point: {#{x}, #{y}}, negative loss: #{neg_loss}")
      # Move to lower left
      maximize(neg_loss)
      true
    end
  end

  # Helpers
  def move(:left, {x, y}), do: {x - 1, y}
  def move(:right, {x, y}), do: {x + 1, y}
  def move(:up, {x, y}), do: {x, y + 1}
  def move(:down, {x, y}), do: {x, y - 1}
end