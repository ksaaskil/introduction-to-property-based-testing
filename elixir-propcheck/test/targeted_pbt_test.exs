defmodule TargetedPbtTest do
  use ExUnit.Case
  use PropCheck
  doctest Pbt

  def path() do
    list(oneof([:left, :right, :up, :down]))
  end

  # property "always works" do
  #   forall path <- path() do
  #     IO.puts("Path has #{length(path)} steps: #{Enum.join(path, ",")}")
  #     true
  #   end
  # end

  property "path" do
    forall_targeted p <- path() do
      # IO.puts("Path has #{length(p)} steps: #{Enum.join(p, ",")}")
      {x, y} = List.foldl(p, {0, 0}, fn v, acc -> move(v, acc) end)
      # move(:left, {0, 0})
      IO.puts("Last point: {#{x}, #{y}}")
      maximize(x - y)
      true
    end
  end

  def move(:left, {x, y}), do: {x - 1, y}
  def move(:right, {x, y}), do: {x + 1, y}
  def move(:up, {x, y}), do: {x, y + 1}
  def move(:down, {x, y}), do: {x, y - 1}

  test "greets the world" do
    assert Pbt.hello() == :world
  end

  def my_type() do
    term()
  end

  def boolean?(_) do
    true
  end
end
