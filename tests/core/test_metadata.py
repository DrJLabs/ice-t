import importlib

import ice_t


def test_version_and_author():
    assert isinstance(ice_t.__version__, str)
    assert ice_t.__version__ == "0.1.0"
    assert ice_t.__author__ == "DrJLabs"


def test_subpackages_have_docstrings():
    subpackages = ["core", "features", "integrations", "utilities"]
    for name in subpackages:
        module = importlib.import_module(f"ice_t.{name}")
        assert module.__doc__, f"{name} should have a docstring"

