"""Temporary test file to trigger CI failure for workflow verification."""

def test_intentional_ci_failure_for_logging():
    """This test intentionally fails to trigger CI logging workflows."""
    raise AssertionError("Intentional CI failure to test logging and metrics.") 