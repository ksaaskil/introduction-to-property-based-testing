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
