from functools import wraps

from dataclasses import dataclass
import hypothesis.strategies as st
from hypothesis.stateful import Bundle, RuleBasedStateMachine, rule, consumes
from hypothesis.strategies._internal.core import composite

from typing import Optional

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
    # TODO: Should this check to not accidentally create the same user as before?
    @rule(target=created_users, user=users())
    def create_new_user(self, user: User):
        # Perform operation on real system
        self._shim.create_user(user)

        # Update model state (`next_state`)
        self._model_state.update(**{user.uid: user})

        # Return value store it into bundle
        return user

    # Test adding an existing user, should raise an exception.
    # User is drawn from the `created_users` bundle.
    @rule(user=created_users)
    @expect_exception(GitlabException)
    def create_existing_user(self, user: User):
        self._shim.create_user(user)

    # Test fetching an existing user, as post-condition both model and state
    # should return the same user
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
