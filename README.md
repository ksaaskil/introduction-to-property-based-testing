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

## Targeted property-based testing

Some notes below for preparing to demo targeted PBT.

### Example: maximize sort time

### [Simulated annealing](https://en.wikipedia.org/wiki/Simulated_annealing)

- Method for finding the global minimum of a function `E(s)` with respect to `s`
- Algorithm:

  0. Choose initial temperature `T`, initial state `s` and compute `e=E(s)`
  1. Generate a candidate ("neighbor") `s'` and compute `e'=E(s')`
  2. With acceptance probability `P(e, e', T)`, move to new state by assigning `s=s'`, `e=e'`
  3. If done, exit. Otherwise, update `T` and move to 1.

- Acceptance probability function `P(e, e', T)` depends on "temperature" `T`
  - When T tends to zero, acceptance probability tends to zero if `e' > e`
  - Large `T`: Transitions to worse states (`e' > e`) are likely
  - Small `T`: Transitions to worse states are unlikely
  - `T=0`: Transitions allowed only to smaller energy states ("greedy" algorithm)
  - Example: `P(e, e', T) = 1` if `e' < e`, otherwise `P(e, e', T) = exp(-(e'-e) / T)`
- Algorithm starts with high value of `T` and then decreases `T` according to _annealing schedule_
- Recap of required parameters:
  - State space `S` and the energy (target) function `E: S -> float`
  - Candidate generator function `neighbor()`
  - Acceptance probability function `P(e, e', T)`
  - Annealing schedule
- Efficient candidate generation requires that you don't "hop around" like crazy: rather make smallish movements
  - Similar to Metropolis-Hastings
  - ...but be careful of being trapped in a local minimum
- Also restarts may help if trapped in a bad environment
  - Keep track of best energy and state so far
- Resources:
  - [Wikipedia](ttps://en.wikipedia.org/wiki/Simulated_annealing)

### Custom neighbor functions

### More variations
