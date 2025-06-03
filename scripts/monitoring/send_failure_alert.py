#!/usr/bin/env python3
"""Send alerts when a new CI failure log is committed.

The script can post a message to Slack or send an email based on
available environment variables. Both delivery methods are optional
and will be skipped if the necessary environment variables are not set.
"""

from __future__ import annotations

from email.message import EmailMessage
import os
from pathlib import Path
import smtplib
from urllib import error as urlerror
from urllib import request

from tools.ci_log_summary import extract_error_lines


def read_summary(log_path: Path) -> str:
    """Create a short message summarizing the log."""
    lines = extract_error_lines(log_path)
    header = f"CI failure log: {log_path.name}\n"
    return header + "\n".join(lines[:20])


def send_slack(message: str) -> bool:
    webhook = os.getenv("SLACK_WEBHOOK_URL")
    if not webhook:
        return False
    data = message.encode()
    req = request.Request(webhook, data=data, headers={"Content-Type": "text/plain"})
    try:
        request.urlopen(req, timeout=10)
    except urlerror.URLError:
        return False
    return True


def send_email(subject: str, body: str) -> bool:
    to_addr = os.getenv("ALERT_EMAIL")
    if not to_addr:
        return False
    msg = EmailMessage()
    msg["From"] = os.getenv("SMTP_USERNAME", "ci-bot@example.com")
    msg["To"] = to_addr
    msg["Subject"] = subject
    msg.set_content(body)

    server = os.getenv("SMTP_SERVER", "localhost")
    port = int(os.getenv("SMTP_PORT", "25"))
    username = os.getenv("SMTP_USERNAME")
    password = os.getenv("SMTP_PASSWORD")

    try:
        with smtplib.SMTP(server, port, timeout=10) as smtp:
            if username and password:
                smtp.login(username, password)
            smtp.send_message(msg)
    except Exception:
        return False
    return True


def main(log_file: str) -> int:
    path = Path(log_file)
    if not path.is_file():
        print(f"Log not found: {path}")
        return 1
    message = read_summary(path)
    sent = send_slack(message)
    sent_email = send_email("CI Failure Alert", message)
    if not sent and not sent_email:
        print("No alert sent - check configuration")
    return 0


if __name__ == "__main__":
    import sys

    if len(sys.argv) != 2:
        print("Usage: send_failure_alert.py <log_file>")
        raise SystemExit(1)
    raise SystemExit(main(sys.argv[1]))
