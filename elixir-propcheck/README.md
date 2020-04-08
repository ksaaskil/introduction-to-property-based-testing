# Property-based testing with [`PropCheck`](https://hexdocs.pm/propcheck/PropCheck.html)

Examples of property-based tests in Elixir. Many of the examples come from [Property-Based Testing with PropEr, Erlang, and Elixir](https://propertesting.com/) book.

## What's in the repo

### Targeted PBT examples

- [`test/tpbt_test.exs`](./test/tpbt_test.exs): Example of targeted path generation
- [`test/tpbt_quicksort_test.exs`](./test/tpbt_quicksort_test.exs): Find pathological lists for naive quicksort implementation
- [`test/tpbt_usernf_test.exs`](./test/tpbt_usernf_test.exs): Example of custom neighbor functions in targeted PBT
- [`test/tpbt_variations_test.exs`](./test/tpbt_variations_test.exs): Wrapping targeted PBT in a `forall` for more varying data

## Instructions

Install [Elixir](https://elixir-lang.org/install.html).

Install dependencies:

```bash
$ mix deps.get
```

Run tests:

```bash
$ mix test
```

Access shell (in Unix-style systems):

```bash
$ MIX_ENV="test" iex -S mix
```

If you're using Windows, you need to set `MIX_ENV` to your environment somehow differently :)

Try example calls in the shell:

```bash
iex> :proper_types.term()
iex> :proper_gen.pick(:proper_types.number())
iex> :proper_gen.pick(:proper_types.atom())
iex> :proper_gen.pick(:proper_types.binary())
iex> :proper_gen.pick(:proper_types.boolean())
iex> :proper_gen.pick(:proper_types.choose(1, 10))
iex> :proper_gen.pick(:proper_types.list(:proper_types.integer()))
# Return character code points
iex> :proper_gen.pick(:proper_types.string())
iex> :proper_gen.pick({:proper_types.boolean(), :proper_types.number()})
```
