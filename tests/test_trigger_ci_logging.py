"""Test to trigger CI failure and verify logging system."""


def test_trigger_ci_logging():
    """This test will fail to trigger CI logging for verification."""
    # Intentionally fail to test CI logging system
    raise AssertionError("Intentional failure to verify CI logging system works")


def test_that_passes():
    """This test passes to ensure not all tests fail."""
    assert 2 + 2 == 4
