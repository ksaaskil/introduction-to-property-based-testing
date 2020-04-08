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

### Targeted property-based testing

- [Targeted property-based testing](http://proper.softlab.ntua.gr/papers/issta2017.pdf), A. Löscher and K. Sagonas, 2017.
  > "We introduce targeted property-based testing, an enhanced form of property-based testing that aims to make the **input generation** component of a property-based testing tool **guided by a search strategy** rather than being completely random"
- [Automating targeted property-based testing](https://proper-testing.github.io/papers/icst2018.pdf), A. Löscher and K. Sagonas, 2018.
  > "To use [targeted PBT], however, the user currently needs to specify a search strategy and also supply all ingredients that the search strategy requires. - [In this paper], we focus on **simulated annealing**, the default search strategy of our tool, and present a technique that **automatically creates all the ingredients** that targeted PBT requires **starting from only a random generator.**"
- [Targeted property-based testing with Applications in Sensor Networks](http://uu.diva-portal.org/smash/record.jsf?pid=diva2%3A1195475&dswid=7548), A. Löscher's PhD thesis, 2018.

  > "This dissertation presents targeted property-based testing, an enhanced form of PBT where the input generation is guided by a search strategy instead of being random, thereby combining the strengths of QuickCheck-like and search-based testing techniques. It furthermore presents an automation for the simulated annealing search strategy that reduces the manual task of using targeted PBT."

- Andreas Löscher:

  - [Google Scholar](https://scholar.google.se/citations?user=E4LXtaEAAAAJ&hl=sv)
  - [LinkedIn](https://www.linkedin.com/in/andreas-loscher/)

- Konstantinos Sagonas:
  - [Google Scholar](https://scholar.google.com/citations?hl=en&user=ijCSV_wAAAAJ&view_op=list_works&sortby=pubdate)
  - [Fascinating papers on PropEr](https://github.com/proper-testing/proper-testing.github.io/blob/master/publications.md)

### Implementations

- [Proper](https://proper-testing.github.io/apidocs/): `?FORALL_TARGETED`
- [`PropCheck.TargetedPBT`](https://hexdocs.pm/propcheck/PropCheck.TargetedPBT.html#content)
- [`hypothesis.target`](https://hypothesis.readthedocs.io/en/latest/details.html#targeted-example-generation)

Also:

- [`QuickTheories`](https://github.com/quicktheories/QuickTheories) has targeted search for coverage

### What is targeted PBT?

- PBT relies on **generators**, functions producing data from given search space
  - Typically sample **a small part of the full search space**
  - Unguided: **no feedback to generator** if our samples are good or bad
- Targeted PBT: **Give feedback to the generator**
  - **Couples test execution to data generation**
  - "This is more like it, well done!"
  - "This is not a good sample, please try again."

### What you lose in targeted PBT

- Complex data generators (recursive)
- Stateful tests
- Generator metrics
- Shrinking (at least partially)
- Variations in data

### What you gain

- Generates data made for the problem at hand
- Can generate data not found with traditional generators
- Can replace complex generators
  - Simplifies generating, for example, unbalanced trees

### "Who's a good boy" a.k.a. how to give treats to generators

- Formulated as an optimization problem
  - Task is to maximize a given function
  - Generator produces data leading to larger values -> reward
  - Generator produces data leading to smaller values -> no reward
- Be careful of local optima
  - Short-term vs. long-term rewards
    -> Non-greedy algorithms

### Generic problem setup

- **Search space** `S`
- **Target function** `E: S -> R`
  - Mapping from search space to real numbers
  - Also known as **energy** or **utility** function
- **Task**: Minimize `E`
  - Equivalent to maximizing `-E`

### Examples of search space `S`

- All lists of integers with length below 1000
- All valid `User` objects with given ID
- All HTTP requests accepted by a server

Examples from [Hypothesis documentation](https://hypothesis.readthedocs.io/en/latest/details.html#targeted-example-generation):

- Number of elements in a collection, or tasks in a queue
- Mean or maximum runtime of a task (or both, if you use `label`)
- Compression ratio for data (perhaps per-algorithm or per-level)
- Number of steps taken by a state machine

### Examples of target function `E`

- Execution time

  - `S` = All lists of integers with length below 1000
  - `E` = (Negative) time to sort the list

- Response time
  - `S` = All HTTP requests accepted by the server
  - `E` = (Negative) server response time

### Motivating example: maximize sort time

This property searches for input data that maximizes the execution time and it indeed fails, finding examples of lists that take more than a second to sort.

```elixir
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
```

### How does it work?

- Simulated annealing as optimization algorithm
  - Non-greedy: probabilistic algorithm that may trade short-term rewards for long-term benefits
  - Originates from physics

### [Simulated annealing](https://en.wikipedia.org/wiki/Simulated_annealing)

- Method for finding the global minimum of a function `E(s)` with respect to `s`
- Algorithm:

  0. Choose initial temperature `T=T_0`, initial state `s=s_0` and compute `e=E(s)`
  1. Generate a candidate ("neighbor") `s'` and compute `e'=E(s')`
  2. With acceptance probability `P(e, e', T)`, move to new state by assigning `s=s'`, `e=e'`
  3. If done, exit. Otherwise, update `T` according to annealing schedule and move to 1.

### Acceptance probability `P(e, e', T)`

- Depends on "temperature" `T`
- In the beginning of the search, `T` is large
- As search progresses, `T -> 0` according to _annealing schedule_
- `T` large: Transitions to higher-energy states (`e' > e`) are likely
- `T` small: Transitions to higher-energy states are unlikely
- `T = 0`: Transitions allowed only to smaller-energy states ("greedy" algorithm)
- Example: `P(e, e', T) = 1` if `e' < e`, otherwise `P(e, e', T) = exp[-(e'-e) / T]`

### Recap of simulated annealing

- Probabilistic, iterative algorithm to minimize given target function
- Requires
  - Candidate generator function `neighbor()`
  - Acceptance probability function `P(e, e', T)`
  - Annealing schedule
  - Initial guess `s_0` and initial temperature `T_0`

### Candidate generation

- Efficient candidate generation requires that you don't "hop around" to random states like crazy: rather try moves to states with similar energy
  - Similar to [Metropolis-Hastings](https://en.wikipedia.org/wiki/Metropolis%E2%80%93Hastings_algorithm)
  - Be careful of local minima
  - Also occasional restarts may help if trapped in a bad environment

### Candidate generation in targeted PBT

- Customizable via custom neighbor function (`user_nf` in `propcheck`)
- Instead of letting framework decide which neighbors to try, you can define your own neighbor function
- Neighbor function takes the previous data point and a tuple of current depth and temperature and returns the next value to try

```elixir
# Always add steps right and down at the end of drawn path
def path_next() do
  fn prev_path, , {_depth, _temperature} ->
    let(
      next_steps <- list(oneof([:right, :down])),
      do: prev_path ++ next_steps
    )
  end
end
```

### Quiz 1

What are the values of `l` in the following case?

```elixir
def list_next() do
  fn _prev_list, , {_depth, _temperature} ->
    [1, 2, 3]
  end
end

property "targeted list generation" do
  forall_targeted l <- user_nf(list(integer()), list_next()) do
    ...
  end
end
```

Answer: `l` is always `[1, 2, 3]`.

### Quiz 2

What's the generated data like in the following case?

```elixir
def list_next() do
  fn prev_list, , {_depth, _temperature} ->
    prev_list
  end
end

property "targeted list generation" do
  forall_targeted l <- user_nf(list(integer()), list_next()) do
    ...
  end
end
```

Answer: `l` is random but fixed, equal to the first randomly drawn list.

### More variations

- With custom neighbor functions, all generated data is a variation of the first drawn value
- You can get more variation by wrapping targeted search in a `forall` block
- Test below executes the `forall` block five times and searches for 10 steps for each block

```elixir
property "targeted path generation with variation", search_steps: 10, numtests: 5 do
  forall p <- path() do
    # Trick to make a generator from value
    p_gen = let(p_ <- p, do: p_)

    forall_targeted p2 <- user_nf(p_gen, path_next()) do
      {x, y} = List.foldl(p2, {0, 0}, fn v, acc -> move(v, acc) end)
      neg_loss = x - y
      IO.puts("Last point: {#{x}, #{y}}, negative loss: #{neg_loss}")
      maximize(neg_loss)
      true
    end
  end
end
```
