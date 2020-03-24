# Examples of PBT with [`hypothesis`](https://hypothesis.readthedocs.io/)

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
