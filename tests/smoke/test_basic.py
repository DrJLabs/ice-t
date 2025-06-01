"""Basic smoke tests."""

def test_import_ice_t():
    """Test that ice_t can be imported."""
    import ice_t
    assert ice_t.__version__

def test_project_structure():
    """Test basic project structure."""
    from pathlib import Path
    src_dir = Path(__file__).parent.parent.parent / "src" / "ice_t"
    assert src_dir.exists()
    assert (src_dir / "__init__.py").exists()
