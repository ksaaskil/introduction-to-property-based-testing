defmodule BookstoreTest do
  use ExUnit.Case
  use PropCheck
  use PropCheck.StateM
  doctest Bookstore

  def title() do
    let s <- utf8() do
      elements([s, String.to_charlist(s)])
    end
  end

  def author() do
    let s <- utf8() do
      elements([s, String.to_charlist(s)])
    end
  end

  def isbn() do
    let(
      isbn <- [
        oneof(['978', '979']),
        let(x <- range(0, 9999), do: to_charlist(x)),
        let(x <- range(0, 999), do: to_charlist(x)),
        frequency([{10, [range(?0, ?9)]}, {1, 'X'}])
      ]
    ) do
      to_string(Enum.join(isbn, "-"))
    end
  end

  test "greets the world" do
    assert Bookstore.hello() == :world
  end
end
