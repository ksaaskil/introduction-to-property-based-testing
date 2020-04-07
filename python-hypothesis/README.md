# Examples of PBT with [`hypothesis`](https://hypothesis.readthedocs.io/)

Examples of property-based testing using the [`Hypothesis`](https://hypothesis.readthedocs.io/en/latest/) library:

- [`test_hypothesis.py`](./test_hypothesis.py): Examples from Hypothesis documentation
- [`test_gitlab_stateful.py`](./test_gitlab_stateful.py): Stateful property-based testing for GitLab-like API

## Instructions

```bash
$ pip install -r requirements.txt
$ pytest
```

Use Hypothesis [plugin](https://hypothesis.readthedocs.io/en/latest/details.html#the-hypothesis-pytest-plugin) to, for example, display statistics:

```bash
# Show statistics
$ pytest --hypothesis-show-statistics
# Reproduce a failure with fixed seed
$ pytest --hypothesis-seed=0
```
