# 🐛 Debug and Fix Playbook

## 📋 Overview
This playbook provides a systematic approach for AI agents to debug issues and implement fixes in the ice-t codebase.

## 🎯 Input Requirements
- **Bug Report**: Clear description of the issue
- **Error Messages**: Stack traces, error logs, or failure descriptions
- **Context**: Where the issue occurs (environment, specific actions, etc.)
- **Expected vs Actual**: What should happen vs what actually happens

## 🔍 Phase 1: Issue Investigation

### 1.1 Gather Information
```bash
# Use semantic search to understand the problem domain
codebase_search("error handling patterns")
codebase_search("similar issue to [describe issue]")

# Find exact error messages or symptoms
grep_search("specific error message")
grep_search("function or class name related to issue")
```

### 1.2 Locate Relevant Code
```bash
# Find files related to the issue
file_search("component_name")
file_search("feature_related_to_bug")

# Examine the problematic area
read_file("path/to/suspected/file.py", start_line, end_line)
```

### 1.3 Understand Current Implementation
- Review the failing code logic
- Check for recent changes using git history
- Identify dependencies and interactions
- Look for similar patterns elsewhere in codebase

## 🧪 Phase 2: Reproduce and Validate

### 2.1 Create Reproduction Test
```python
# Create a test that reproduces the bug
def test_reproduce_bug():
    """Test that reproduces the reported bug."""
    # Setup conditions that trigger the bug
    setup_data = create_test_data()

    # Execute the problematic action
    with pytest.raises(ExpectedError):  # or assert for wrong behavior
        problematic_function(setup_data)
```

### 2.2 Run Targeted Tests
```bash
# Run tests related to the bug area
python scripts/testing/adaptive_test_runner.py --changed-files src/problematic/file.py

# Run specific test categories
python -m pytest tests/unit/test_specific_area.py -v
python -m pytest tests/integration/ -k "test_related_functionality"
```

## 🔧 Phase 3: Implement Fix

### 3.1 Design Solution
- Identify root cause of the issue
- Consider edge cases and side effects
- Ensure fix aligns with project architecture
- Plan minimal, focused changes

### 3.2 Implement Fix
```python
# Example fix structure
# ... existing code ...
def fixed_function(input_data: InputDTO) -> OutputDTO:
    """Fixed function with proper error handling."""
    # Add validation
    if not input_data or not input_data.required_field:
        raise ValidationError("Required field missing")

    # Add error handling
    try:
        result = process_data(input_data)
        return OutputDTO(result=result)
    except SpecificException as e:
        logger.error(f"Processing failed: {e}")
        raise ProcessingError(f"Unable to process data: {e}")
# ... existing code ...
```

### 3.3 Update Tests
```python
# Update existing tests to cover the fix
def test_fixed_functionality():
    """Test that the fix works correctly."""
    # Test successful case
    valid_input = create_valid_input()
    result = fixed_function(valid_input)
    assert result.is_valid()

    # Test error cases
    with pytest.raises(ValidationError):
        fixed_function(None)

    with pytest.raises(ProcessingError):
        fixed_function(create_invalid_input())
```

## ✅ Phase 4: Validation and Testing

### 4.1 Run Comprehensive Tests
```bash
# Run tests for changed areas
python scripts/testing/adaptive_test_runner.py --changed-files src/fixed/file.py tests/test_fixed_area.py

# Run broader test suite to check for regressions
python scripts/testing/adaptive_test_runner.py --integration

# Run specific markers that might be affected
python -m pytest -m "unit and not slow" tests/
```

### 4.2 Quality Checks
```bash
# Run linting and type checking
ruff check . && mypy src/ tests/

# Check test coverage
python -m pytest --cov=src/ice_t --cov-report=term-missing
```

### 4.3 Manual Verification
- Test the fix in the reported scenario
- Verify no new issues are introduced
- Check edge cases and boundary conditions
- Confirm error messages are helpful

## 📊 Phase 5: Documentation and Cleanup

### 5.1 Update Documentation
- Add comments explaining the fix logic
- Update docstrings if behavior changed
- Document any new error conditions
- Update API documentation if applicable

### 5.2 Add Regression Prevention
```python
# Add tests to prevent future regressions
def test_regression_prevention_issue_123():
    """Regression test for issue #123: [brief description]."""
    # Test the specific scenario that was broken
    # Ensure it continues to work in the future
    pass
```

## 🔄 Common Debug Patterns

### Error Handling Issues
```python
# Before: Unclear error
def problematic_function(data):
    return data.process()  # AttributeError if data is None

# After: Clear error handling
def fixed_function(data: Optional[DataType]) -> ProcessedData:
    if data is None:
        raise ValueError("Data cannot be None")

    try:
        return data.process()
    except AttributeError as e:
        raise ProcessingError(f"Invalid data format: {e}")
```

### Validation Issues
```python
# Before: Silent failures
def process_user(user_data):
    if user_data.email:  # Wrong: allows empty string
        send_email(user_data.email)

# After: Proper validation
def process_user(user_data: UserDTO) -> None:
    if not user_data.email or "@" not in user_data.email:
        raise ValidationError("Valid email required")

    send_email(user_data.email)
```

### Performance Issues
```python
# Before: Inefficient queries
def get_users():
    users = []
    for user_id in user_ids:
        user = database.get_user(user_id)  # N+1 query problem
        users.append(user)
    return users

# After: Optimized queries
def get_users():
    return database.get_users_batch(user_ids)  # Single query
```

## 🚨 Emergency Debug Checklist

### Quick Diagnostic Steps
1. **Check Recent Changes**: What was modified recently?
2. **Review Error Logs**: What do the logs show?
3. **Verify Environment**: Are dependencies/configs correct?
4. **Check Test Status**: What tests are failing?
5. **Isolate Variables**: Can you reproduce in isolation?

### Fast Fix Patterns
- **Import Errors**: Check `__init__.py` files and imports
- **Type Errors**: Add missing type annotations
- **Test Failures**: Update test expectations or fix implementation
- **Linting Issues**: Run `ruff check --fix .`

## 📝 Communication Template

### Bug Fix PR Description
```markdown
## 🐛 Bug Fix: [Brief Description]

### Problem
- **Issue**: [Description of the bug]
- **Symptoms**: [What users/tests experienced]
- **Root Cause**: [Technical explanation]

### Solution
- **Approach**: [How the fix works]
- **Changes**: [List of modified files/functions]
- **Testing**: [How the fix was validated]

### Verification
- [ ] Bug reproduction test added
- [ ] Fix implementation tested
- [ ] No regressions introduced
- [ ] Linting and type checking pass
- [ ] Documentation updated if needed
```

## 🎯 Success Criteria

A successful bug fix should:
- ✅ Resolve the reported issue completely
- ✅ Include tests that prevent regression
- ✅ Not introduce new bugs or issues
- ✅ Follow project coding standards
- ✅ Include clear, maintainable code
- ✅ Have appropriate error handling
- ✅ Be documented appropriately

## 💡 Best Practices

1. **Start Small**: Make minimal changes to fix the issue
2. **Test First**: Write reproduction test before fixing
3. **Think Holistically**: Consider side effects and edge cases
4. **Document Context**: Explain why the fix works
5. **Prevent Recurrence**: Add tests and validation
6. **Follow Architecture**: Maintain consistency with project patterns
