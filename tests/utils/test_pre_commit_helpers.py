"""Tests for tools.pre_commit_helpers utilities."""

from __future__ import annotations

from pathlib import Path
from types import SimpleNamespace

import builtins
import sys
from importlib import import_module

import pytest

ROOT = Path(__file__).resolve().parents[2]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

helpers = import_module("tools.pre_commit_helpers")


def write(path: Path, text: str) -> Path:
    path.write_text(text)
    return path


def test_trailing_whitespace(tmp_path: Path) -> None:
    file_path = write(tmp_path / "sample.txt", "line1  \nline2\n")
    changed = helpers.trailing_whitespace([str(file_path)])
    assert changed is True
    assert file_path.read_text() == "line1\nline2\n"

    # running again should produce no change
    changed = helpers.trailing_whitespace([str(file_path)])
    assert changed is False


def test_end_of_file(tmp_path: Path) -> None:
    file_path = write(tmp_path / "eof.txt", "no-newline")
    changed = helpers.end_of_file([str(file_path)])
    assert changed is True
    assert file_path.read_text() == "no-newline\n"

    changed = helpers.end_of_file([str(file_path)])
    assert changed is False


def test_check_merge_conflict(tmp_path: Path) -> None:
    conflict_file = write(
        tmp_path / "conflict.txt",
        "<<<<<<< HEAD\nvalue\n=======\nother\n>>>>>>> branch\n",
    )
    clean_file = write(tmp_path / "clean.txt", "ok\n")

    ok = helpers.check_merge_conflict([str(conflict_file), str(clean_file)])
    assert ok is False

    # With only clean file it should pass
    ok = helpers.check_merge_conflict([str(clean_file)])
    assert ok is True


def test_check_json(tmp_path: Path) -> None:
    good = write(tmp_path / "good.json", "{\n  \"a\": 1\n}\n")
    bad = write(tmp_path / "bad.json", "{ invalid json }")

    assert helpers.check_json([str(good)]) is True
    assert helpers.check_json([str(bad)]) is False


def test_check_yaml_with_mock(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    calls: list[str] = []

    def fake_safe_load(fh: builtins.object) -> None:
        calls.append(fh.read())

    monkeypatch.setattr(helpers, "yaml", SimpleNamespace(safe_load=fake_safe_load))

    good = write(tmp_path / "good.yaml", "key: value\n")
    assert helpers.check_yaml([str(good)]) is True
    assert calls, "safe_load should have been called"

    def raising_safe_load(_: builtins.object) -> None:
        raise ValueError("boom")

    monkeypatch.setattr(helpers, "yaml", SimpleNamespace(safe_load=raising_safe_load))
    bad = write(tmp_path / "bad.yaml", "invalid: [\n")
    assert helpers.check_yaml([str(bad)]) is False


def test_security_check(tmp_path: Path) -> None:
    insecure = write(tmp_path / "bad.py", "import pdb\npdb.set_trace()\n")
    secure = write(tmp_path / "good.py", "print('hi')\n")

    assert helpers.security_check([str(insecure), str(secure)]) is False
    assert helpers.security_check([str(secure)]) is True
