# Pbt

Example of property-based tests in Elixir.

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
