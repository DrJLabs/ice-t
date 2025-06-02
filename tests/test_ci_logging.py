"""Test file to trigger CI failure for testing logging mechanism."""


def test_intentional_failure():
    """This test will intentionally fail to trigger CI logging."""
    # This will cause CI to fail and trigger our logging workflows
    raise AssertionError("Intentional failure to test CI logging mechanism")


def test_that_passes():
    """This test passes to ensure not all tests fail."""
    assert True
