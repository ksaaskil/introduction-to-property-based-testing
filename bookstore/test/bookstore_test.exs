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

  def precondition(_state, {:call, _mod, _fun, _args}) do
    true
  end

  def postcondition(_state, {:call, _mod, _fun, _args}, _res) do
    true
  end

  def next_state(state, _res, {:call, _mod, _fun, _args}) do
    new_state = state
    new_state
  end
end
