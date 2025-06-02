import ice_t
import ice_t.features


def test_features_module_docstring():
    """The features package should have a docstring."""
    assert ice_t.features.__doc__
