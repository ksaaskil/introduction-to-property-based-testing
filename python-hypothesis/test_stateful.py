import shutil
import tempfile
from functools import wraps

from collections import defaultdict
from dataclasses import dataclass
import hypothesis.strategies as st
from hypothesis.database import DirectoryBasedExampleDatabase
from hypothesis.stateful import Bundle, RuleBasedStateMachine, invariant, rule, consumes
from hypothesis.strategies._internal.core import composite

from typing import Optional

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
def users(draw):
    uid = draw(st.uuids())
    name = draw(st.text())
    return User(uid=str(uid), name=name)

class GitlabException(Exception):
    pass

# Fake shim, should be replaced by actual system calls
class GitlabShim:
    def __init__(self):
        self._state = {}

    def create_user(self, user: User):
        if user.uid in self._state:
            raise GitlabException("User exists")
        self._state.update(**{user.uid: user})

    def delete_user(self, uid: str):
        self._state.pop(uid)

    def prepare(self):
        pass

    def fetch_user(self, uid: str) -> Optional[User]:
        return self._state.get(uid, None)

    def teardown(self):
        self._state = {}

def expect_exception(expected_exception_cls):
    def wrap(func):
        @wraps(func)
        def f(*args, **kwargs):
            try:
                func(*args, **kwargs)
            except Exception as e:
                assert isinstance(e, expected_exception_cls), "Should have raised {}, got {}".format(expected_exception_cls, type(e))
                return
            raise Exception("Should have raised")
        return f

    return wrap

class GitlabStateful(RuleBasedStateMachine):
    def __init__(self):
        super().__init__()
        self._model_state = {}

        self._shim = GitlabShim()
        self._shim.prepare()

    created_users = Bundle("users")

    # Create new user
    # (Should have a check to not accidentally create the same user as before?) 
    @rule(target=created_users, user=users())
    def create_new_user(self, user: User):
        # Perform operation on real system
        self._shim.create_user(user)

        # Update model state (`next_state`)
        self._model_state.update(**{user.uid: user})

        # Return value store it into bundle
        return user

    @rule(user=created_users)
    @expect_exception(GitlabException)
    def create_existing_user(self, user: User):
        self._shim.create_user(user)

    @rule(user=created_users)
    def get_existing_user(self, user: User):
        fetched_user = self._shim.fetch_user(user.uid)

        model_user = self._model_state[user.uid]

        assert fetched_user == model_user

    @rule(user=users())
    def get_non_existing_user(self, user: User):
        fetched_user = self._shim.fetch_user(user.uid)
        assert fetched_user is None

    @rule(user=consumes(created_users))
    def delete_user(self, user: User):
        self._shim.delete_user(user.uid)
        self._model_state.pop(user.uid)


TestGitlabShim = GitlabStateful.TestCase
