#!/usr/bin/env python3
"""
Test file to cause CI failure for testing log collection.
"""

# This will cause a syntax error
def broken_function(
    print("This is intentionally broken syntax")
    return "failure"

if __name__ == "__main__":
    broken_function() 