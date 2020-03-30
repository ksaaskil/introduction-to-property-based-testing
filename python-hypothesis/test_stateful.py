import shutil
import tempfile

from collections import defaultdict
from dataclasses import dataclass
import hypothesis.strategies as st
from hypothesis.database import DirectoryBasedExampleDatabase
from hypothesis.stateful import Bundle, RuleBasedStateMachine, invariant, rule
from hypothesis.strategies._internal.core import composite

# Could one do stateful testing more simply by using recursive, deferred, etc. to create lists of operations to try out?

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
    # One could store, for example, random user IDs here.
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

@dataclass
class User:
    uid: str
    name: str

@composite
def user_st(draw):
    uid = draw(st.uuids())
    name = draw(st.text())
    return User(uid=str(uid), name=name)


class GitlabShim:
    def __init__(self):
        pass

    def create_user(self, user: User):
        pass

    def prepare(self):
        pass

    def teardown(self):
        pass


class GitlabStateful(RuleBasedStateMachine):
    def __init__(self):
        super().__init__()
        self._model_state = {}

        self._shim = GitlabShim()
        self._shim.prepare()

    users = Bundle("users")

    # Rule for drawing users and storing them to bundle
    @rule(target=users, user=user_st())
    def add_user(self, user):
        return user

    # Do something with a drawn user
    @rule(user=users)
    def create_user(self, user: User):
        # Perform operation on real system
        self._shim.create_user(user)

        # Perform operation on model
        self._model_state.update(**{user.uid: user})

TestGitlabShim = GitlabStateful.TestCase
