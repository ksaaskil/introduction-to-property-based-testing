# Introduction to property-based testing

See the slides at [https://ksaaskil.github.io/introduction-to-property-based-testing/](https://ksaaskil.github.io/introduction-to-property-based-testing/).

## [`elixir-propcheck`](./elixir-propcheck)

Examples in [Elixir](https://elixir-lang.org/) reside in [elixir-propcheck/](./elixir-propheck) folder.

The project was initialized using [`mix`](https://elixir-lang.org/getting-started/mix-otp/introduction-to-mix.html):

```bash
$ mix new elixir-propcheck --app pbt
```

`mix` is installed with [Elixir](https://elixir-lang.org/install.html).
)

## [`bookstore`](./bookstore)

Example of stateful property-based testing from [PropEr testing book](https://propertesting.com/).

## [`python-hypothesis`](./python-hypothesis)

Examples of property-based testing using the [`Hypothesis`](https://hypothesis.readthedocs.io/en/latest/) library:

- [`python-hypothesis/test_hypothesis.py`](./python-hypothesis/test_hypothesis.py): Examples from Hypothesis documentation
- [`python-hypothesis/test_gitlab_stateful.py`](./python-hypothesis/test_gitlab_stateful.py): Stateful property-based testing for GitLab-like API

## [`erlang-targeted-pbt`](./erlang-targeted-pbt)

Examples of targeted property-based testing in [Erlang](https://www.erlang.org/). Project initialized with [rebar3](https://www.rebar3.org/):

```bash
$ rebar3 new lib erlang-targeted-pbt
```
