from hypothesis import given, target, settings, Phase, Verbosity
import hypothesis.strategies as some
import functools
import math


def with_logging(logger):
    """Simple helper for understanding what's going on in targeted PBT.
    """

    def wrapper(func):
        @functools.wraps(func)
        def f(*args, **kwargs):
            logger(
                "Calling {} with args: {}, kwargs: {}".format(
                    func.__name__,
                    ",".join(args),
                    ",".join(
                        ["{}={}".format(key, value) for key, value in kwargs.items()]
                    ),
                )
            )
            return func(*args, **kwargs)

        return f

    return wrapper


# @with_logging(print)


@given(d=some.floats().filter(lambda x: abs(x) < 100))
@settings(
    max_examples=1000,
    verbosity=Verbosity.verbose,
    phases=[
        Phase.generate,
        Phase.target,
        Phase.shrink,
    ],  # Skip Phase.reuse to not run previous counter-examples
)
def test_targeting_square_loss(d):
    """Contrived example of targeting properties.
    """
    # Assume this value triggers a bug
    target_value = 42

    should_fail = abs(d - target_value) < 0.5
    if should_fail:
        print("Failing with value {}".format(d))
        raise Exception("Critically close to {}, got {}".format(target_value, d))

    # Target the value
    loss = math.pow((d - target_value), 2.0)
    target(-loss)
