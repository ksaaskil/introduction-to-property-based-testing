from hypothesis import given
import hypothesis.strategies as some
import functools


def log(*args, **kwargs):
    print(*args, **kwargs)


def with_logging(logger):
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


@given(s=some.integers())
@with_logging(log)
def test_string2(s):
    # assert isinstance(s, str)
    pass
