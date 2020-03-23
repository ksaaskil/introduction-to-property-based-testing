defmodule PbtTest do
  use ExUnit.Case
  use PropCheck
  doctest Pbt

  property "always works" do
    forall type <- my_type() do
      boolean?(type)
    end
  end

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
