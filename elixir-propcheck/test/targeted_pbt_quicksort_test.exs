defmodule TargetedPbtQuickSortTest do
  use ExUnit.Case
  use PropCheck, default_opts: [numtests: 100, search_steps: 1000]
  doctest Pbt

  # Test quicksort with regular properties
  # This passes as all generated lists are (a) short and (b) nice
  property "regular quick sort", [:verbose] do
    lists = list(integer())
    short_lists = such_that(l <- lists, when: length(l) < 10000)

    forall l <- short_lists do
      t0 = :erlang.monotonic_time(:millisecond)
      quick_sort(l)
      t1 = :erlang.monotonic_time(:millisecond)
      spent = t1 - t0
      collect(spent < 5, to_range(10, spent))
    end
  end

  property "targeted quick sort", [:verbose, :noshrink, search_steps: 500] do
    lists = list(integer())
    short_lists = such_that(l <- lists, when: length(l) < 100_000)

    forall_targeted l <- short_lists do
      t0 = :erlang.monotonic_time(:millisecond)
      quick_sort(l)
      t1 = :erlang.monotonic_time(:millisecond)
      spent = t1 - t0
      maximize(spent)
      spent < 1000
    end
  end

  def to_range(m, n) do
    base = div(n, m)
    {base * m, (base + 1) * m}
  end

  # Functions under test
  def quick_sort([]), do: []

  def quick_sort([head | tail]) do
    quick_sort(for x <- tail, x < head, do: x) ++
      [head] ++
      quick_sort(for x <- tail, x >= head, do: x)
  end
end
