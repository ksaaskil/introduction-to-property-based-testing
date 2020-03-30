from hypothesis import given, event
import hypothesis.strategies as some

# Define input data by specifiyng strategies in the `@given` block
@given(some.integers(), some.integers())
def test_ints_are_commutative(x, y):
    assert x + y == y + x

# You can also name the variables with keywords
@given(x=some.integers(), y=some.integers())
def test_ints_cancel(x, y):
    assert (x + y) - y == x

# An example of a symmetric property
@given(some.lists(some.integers()))
def test_reversing_twice_gives_same_list(xs):
    ys = list(xs)
    ys.reverse()
    ys.reverse()
    assert xs == ys

# Another example of a symmetric property for encoding and decoding
def encode(input_string):
    if not input_string:
        return []
    count = 1
    prev = ""
    lst = []
    for character in input_string:
        if character != prev:
            if prev:
                entry = (prev, count)
                lst.append(entry)
            count = 1
            prev = character
        else:
            count += 1
    entry = (character, count)
    lst.append(entry)
    return lst


def decode(lst):
    q = ""
    for character, count in lst:
        q += character * count
    return q

@given(some.text())
def test_decode_inverts_encode(s):
    assert decode(encode(s)) == s

# One can compose generators to generate e.g. tuples of booleans and text
@given(some.tuples(some.booleans(), some.text()))
def test_look_tuples_work_too(t):
    assert len(t) == 2
    assert isinstance(t[0], bool)
    assert isinstance(t[1], str)



# Simple sort function for an example-based test
def my_sort(l):
    return sorted(l)

# Regular example-based unit test
def test_mysort():
    l = [5, 3, 2, 1, 6]
    l_sorted = my_sort(l)
    assert l_sorted == [1, 2, 3, 5, 6]

# Property-based test for sorting function
@given(l=some.lists(some.integers()))
def test_my_sort(l):
    l_sorted = my_sort(l)
    assert len(l_sorted) == len(l)
    assert set(l_sorted) == set(l)

    def length_to_range(n):
        base = 5
        div = n // base
        return div * base, (div + 1) * base

    length_range = length_to_range(len(l))
    # Use `event` to collect statistics, a very important feature
    # to understand what data you're generating
    event("input list length in range {}-{}".format(*length_range))
    for i in range(len(l) - 1):
        assert l_sorted[i] <= l_sorted[i + 1]

# Use `data` if your generated data depends on the execution of your tests
# If you need values that are affected by previous draws but which don’t depend on the execution of your test,
# stick to the simpler @composite.
@given(some.data())
def test_draw_sequentially(data):
    x = data.draw(some.integers(), label="First number")
    y = data.draw(some.integers(min_value=x), label="Second number")
    assert x <= y


#The @composite decorator lets you combine other strategies in more or less arbitrary ways. It’s probably the main thing you’ll want to use for complicated custom strategies.
# draw(s) is a function that should be thought of as returning s.example(), except that the result is reproducible and will minimize correctly. The decorated function has the initial argument removed from the list, but will accept all the others in the expected order.
# Get an example via: `list_and_index.example()`.
@some.composite
def list_and_index(draw, elements=some.integers()):
    xs = draw(some.lists(elements, min_size=1))
    i = draw(some.integers(min_value=0, max_value=len(xs)-1))
    return (xs, i)
