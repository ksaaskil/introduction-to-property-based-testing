import shutil
import tempfile

from collections import defaultdict
import hypothesis.strategies as st
from hypothesis.database import DirectoryBasedExampleDatabase
from hypothesis.stateful import Bundle, RuleBasedStateMachine, invariant, rule

class DatabaseComparison(RuleBasedStateMachine):
    def __init__(self):
        super().__init__()
        # Define the system under test
        self.tempd = tempfile.mkdtemp()
        self.database = DirectoryBasedExampleDatabase(self.tempd)

        # State of the model.
        # Transitions are defined in the rules itself.
        self.model = defaultdict(set)

    # Bundles are used for storing "draws" during the stateful test.
    # One could store, for example, randomly drawn users here.
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
        # What does model do when this operation is run?
        # This is a "`next_state` transition"
        self.model[k].discard(v)

        # What does actual system do when this operation is run?
        self.database.delete(k, v)
        # Should post conditions be here in the operations?

    @rule(k=keys)
    def values_agree(self, k):
        assert set(self.database.fetch(k)) == self.model[k]

    @invariant()
    def always_true(self):
        # Somehow compare model state and actual response here?
        return True

    def teardown(self):
        shutil.rmtree(self.tempd)


TestDBComparison = DatabaseComparison.TestCase
