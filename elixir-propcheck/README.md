# Pbt

Example of property-based tests in Elixir.

## Instructions

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

Example calls in the shell:

```bash
iex> :proper_types.term()
iex> :proper_gen.pick(:proper_types.number())
```
