import shutil
import tempfile

from collections import defaultdict
import hypothesis.strategies as st
from hypothesis.database import DirectoryBasedExampleDatabase
from hypothesis.stateful import Bundle, RuleBasedStateMachine, rule


class DatabaseComparison(RuleBasedStateMachine):
    def __init__(self):
        super(DatabaseComparison, self).__init__()
        self.tempd = tempfile.mkdtemp()
        self.database = DirectoryBasedExampleDatabase(self.tempd)
        self.model = defaultdict(set)

    keys = Bundle("keys")
    values = Bundle("values")

    @rule(target=keys, k=st.binary())
    def add_key(self, k):
        return k

    @rule(target=values, v=st.binary())
    def add_value(self, v):
        return v

    @rule(k=keys, v=values)
    def save(self, k, v):
        self.model[k].add(v)
        self.database.save(k, v)

    @rule(k=keys, v=values)
    def delete(self, k, v):
        self.model[k].discard(v)
        self.database.delete(k, v)

    @rule(k=keys)
    def values_agree(self, k):
        assert set(self.database.fetch(k)) == self.model[k]

    def teardown(self):
        shutil.rmtree(self.tempd)


TestDBComparison = DatabaseComparison.TestCase
