import ice_t
import ice_t.core


def test_package_version():
    """Ensure ice_t exposes a version string."""
    assert isinstance(ice_t.__version__, str)
    assert ice_t.__version__


def test_core_module_docstring():
    """The core package should have a docstring."""
    assert ice_t.core.__doc__

