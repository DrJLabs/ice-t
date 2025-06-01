def setup_module():
    import pytest

    from nltk.parse.malt import MaltParser

    try:
        depparser = MaltParser()
    except (AssertionError, LookupError):
        pytest.skip("MaltParser is not available")
