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

### What is targeted PBT?

- PBT relies on **generators**, functions producing data from given search space
  - Typically sample **a small part of the full search space**
  - Unguided: **no feedback to generator** if our samples are good or bad
- Targeted PBT: **Give feedback to the generator**
  - **Couples test execution to data generation**
  - "This is more like it, well done!"
  - "This is not a good sample, please try again."

### "Who's a good boy" a.k.a. how to give treats to generators

- Formulated as an optimization problem
  - Task is to maximize a given function
  - Generator produces data leading to larger values -> reward
  - Generator produces data leading to smaller values -> no reward
- Be careful of local optima
  - Short-term vs. long-term rewards
  - Non-greedy algorithms

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

### Examples of target function `E`

- Execution time

  - `S` = All lists of integers with length below 1000
  - `E` = (Negative) time to sort the list

- Response time
  - `S` = All HTTP requests accepted by the server
  - `E` = (Negative) server response time

### Motivating example: maximize sort time

### [Simulated annealing](https://en.wikipedia.org/wiki/Simulated_annealing)

- Method for finding the global minimum of a function `E(s)` with respect to `s`
- Algorithm:

  0. Choose initial temperature `T=T_0`, initial state `s=s_0` and compute `e=E(s)`
  1. Generate a candidate ("neighbor") `s'` and compute `e'=E(s')`
  2. With acceptance probability `P(e, e', T)`, move to new state by assigning `s=s'`, `e=e'`
  3. If done, exit. Otherwise, update `T` according to annealing schedule and move to 1.

- Acceptance probability function `P(e, e', T)` depends on "temperature" `T`
  - In the beginning of the search, `T` is large
  - As search progresses, `T -> 0` according to _annealing schedule_
  - `T` large: Transitions to higher-energy states (`e' > e`) are likely
  - `T` small: Transitions to higher-energy states are unlikely
  - `T = 0`: Transitions allowed only to smaller-energy states ("greedy" algorithm)
  - Example: `P(e, e', T) = 1` if `e' < e`, otherwise `P(e, e', T) = exp[-(e'-e) / T]`
- Recap of requirements:
  - Candidate generator function `neighbor()`
  - Acceptance probability function `P(e, e', T)`
  - Annealing schedule
  - Initial guess `s_0` and initial temperature `T_0`
- Efficient candidate generation requires that you don't "hop around" to random states like crazy: rather try moves to states with similar energy
  - Similar to Metropolis-Hastings
  - Be careful of local minima
  - Also occasional restarts may help if trapped in a bad environment
- Resources
  - [Wikipedia](ttps://en.wikipedia.org/wiki/Simulated_annealing)

### Custom neighbor functions

### More variations

### What you lose

- Complex data generators (recursive)
- Gathering metrics
- Stateful testing
- Shrinking
- Variations in data
