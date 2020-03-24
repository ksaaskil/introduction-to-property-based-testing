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

  def isbn(state), do: elements(Map.keys(state))

  def title(s) do
    elements(for {_, title, _, _, _} <- Map.values(s), do: partial(title))
  end

  def partial(string) do
    string = IO.chardata_to_string(string)
    l = String.length(string)

    let {start, len} <- {range(0, l), non_neg_integer()} do
      String.slice(string, start, len)
    end
  end

  property "bookstore stateful ops", [:verbose] do
    forall cmds <- commands(__MODULE__) do
      {:ok, apps} = Application.ensure_all_started(:bookstore)
      Bookstore.DB.setup()
      {history, state, result} = run_commands(__MODULE__, cmds)
      Bookstore.DB.teardown()
      for app <- apps, do: Application.stop(app)

      (result == :ok)
      |> aggregate(command_names(cmds))
      |> when_fail(
        IO.puts("""
        History: #{inspect(history)}
        State: #{inspect(state)}
        Result: #{inspect(result)}
        """)
      )
    end
  end

  def initial_state(), do: %{}

  def command(state) do
    always_possible = [
      {:call, BookShim, :add_book_new, [isbn(), title(), author(), 1, 1]},
      {:call, BookShim, :find_book_by_title_unknown, [title()]}
    ]

    relies_on_state =
      case Map.equal?(state, %{}) do
        true ->
          []

        false ->
          s = state

          [
            {:call, BookShim, :add_book_existing, [isbn(s), title(), author(), 1, 1]},
            {:call, BookShim, :find_book_by_title_matching, [title(s)]}
          ]
      end

    oneof(always_possible ++ relies_on_state)
  end

  def has_isbn(s, isbn) do
    Map.has_key?(s, isbn)
  end

  def like_title(map, title) do
    Enum.any?(
      Map.values(map),
      fn {_, t, _, _, _} -> contains?(t, title) end
    )
  end

  def contains?(str_or_chars_full, str_or_char_pattern) do
    string = IO.chardata_to_string(str_or_chars_full)
    pattern = IO.chardata_to_string(str_or_char_pattern)
    String.contains?(string, pattern)
  end

  def precondition(s, {:call, _, :add_book_new, [isbn | _]}) do
    not has_isbn(s, isbn)
  end

  def precondition(s, {:call, _, :find_book_by_title_unknown, [title]}) do
    not has_isbn(s, title)
  end

  def precondition(s, {:call, _, :find_book_by_title_matching, [title]}) do
    like_title(s, title)
  end

  def precondition(s, {:call, _, _, [isbn | _]}) do
    has_isbn(s, isbn)
  end

  def postcondition(_state, {:call, _mod, _fun, _args}, _res) do
    true
  end

  def next_state(state, _res, {:call, _mod, _fun, _args}) do
    new_state = state
    new_state
  end
end
