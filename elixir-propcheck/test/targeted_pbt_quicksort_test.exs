defmodule TargetedPbtQuickSortTest do
  use ExUnit.Case
  use PropCheck, default_opts: [numtests: 100, search_steps: 1000]
  doctest Pbt

  property "regular quick sort", [:verbose] do
    forall l <- lists() do
      t0 = :erlang.monotonic_time(:millisecond)
      sort(l)
      t1 = :erlang.monotonic_time(:millisecond)
      spent = t1 - t0
      collect(spent < 5, to_range(10, spent))
    end
  end

  property "targeted quick sort", [:verbose, :noshrink] do
    forall_targeted l <- such_that(l <- list(integer()), when: length(l) < 10000) do
      t0 = :erlang.monotonic_time(:millisecond)
      sort(l)
      t1 = :erlang.monotonic_time(:millisecond)
      spent = t1 - t0
      maximize(spent)
      spent < 50
    end
  end

  def lists() do
    gen = list(integer())
    such_that(l <- gen, when: length(l) < 10000)
  end

  def to_range(m, n) do
    base = div(n, m)
    {base * m, (base + 1) * m}
  end

  # Functions under test
  def sort([]), do: []

  def sort([head | tail]) do
    sort(for x <- tail, x < head, do: x) ++
      [head] ++
      sort(for x <- tail, x >= head, do: x)
  end
end
