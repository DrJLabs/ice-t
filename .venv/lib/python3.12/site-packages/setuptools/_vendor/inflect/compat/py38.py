import sys

if sys.version_info > (3, 9):
    from typing import Annotated
else:  # pragma: no cover
    from typing import Annotated  # noqa: F401
