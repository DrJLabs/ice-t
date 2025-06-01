# ♻️ Code Refactoring Playbook

## 📋 Overview
This playbook provides systematic guidance for AI agents to safely refactor and improve code quality in the ice-t codebase while maintaining functionality.

## 🎯 Input Requirements
- **Target Code**: Specific files, functions, or modules to refactor
- **Refactoring Goal**: What improvement is being made (performance, readability, maintainability)
- **Success Criteria**: How to measure if the refactoring was successful
- **Constraints**: Any limitations or requirements to consider

## 🔍 Phase 1: Analysis and Planning

### 1.1 Understand Current Implementation
```bash
# Examine the code to be refactored
read_file("target/file.py", start_line, end_line)

# Find related code and dependencies
codebase_search("functions that use target_function")
grep_search("import.*target_module")

# Check test coverage
codebase_search("tests for target_functionality")
```

### 1.2 Identify Refactoring Opportunities
Common refactoring patterns to look for:
- **Code Duplication**: Similar logic in multiple places
- **Long Functions**: Functions doing too many things
- **Complex Conditionals**: Nested if/else that could be simplified
- **Poor Naming**: Variables/functions with unclear names
- **Tight Coupling**: Classes/modules too dependent on each other
- **Magic Numbers**: Hard-coded values that should be constants

### 1.3 Plan the Refactoring
- Define specific improvements to make
- Identify breaking changes or risks
- Plan refactoring in small, safe steps
- Ensure backward compatibility if needed

## 🧪 Phase 2: Establish Safety Net

### 2.1 Ensure Comprehensive Test Coverage
```bash
# Run tests for the target area
python scripts/testing/adaptive_test_runner.py --changed-files src/target/file.py

# Check coverage levels
python -m pytest --cov=src/ice_t/target --cov-report=term-missing
```

### 2.2 Add Missing Tests if Needed
```python
# Add characterization tests for existing behavior
def test_current_behavior_before_refactoring():
    """Test that captures current behavior before refactoring."""
    # Test all current inputs and outputs
    # This ensures refactoring doesn't change behavior
    input_data = create_test_input()
    result = target_function(input_data)
    
    # Assert current behavior (even if not ideal)
    assert result == expected_current_result
```

### 2.3 Create Baseline Measurements
```python
# Performance baseline if refactoring for performance
def test_performance_baseline():
    """Establish performance baseline before refactoring."""
    import time
    start_time = time.time()
    
    # Run the operation
    for _ in range(100):
        target_function(test_data)
    
    duration = time.time() - start_time
    # Document current performance for comparison
    assert duration < 10.0  # Current acceptable threshold
```

## 🔧 Phase 3: Implement Refactoring

### 3.1 Small, Incremental Changes

#### Extract Method Refactoring
```python
# Before: Long function doing multiple things
def process_user_data(user_data):
    # Validation logic (20 lines)
    if not user_data:
        raise ValueError("User data required")
    # ... more validation
    
    # Processing logic (30 lines)
    processed = {}
    # ... complex processing
    
    # Formatting logic (15 lines)
    formatted = format_output(processed)
    return formatted

# After: Extracted methods
def process_user_data(user_data: UserData) -> ProcessedUser:
    """Process user data through validation, processing, and formatting."""
    validated_data = _validate_user_data(user_data)
    processed_data = _process_validated_data(validated_data)
    return _format_processed_data(processed_data)

def _validate_user_data(user_data: UserData) -> ValidatedUserData:
    """Validate user data and return validated version."""
    if not user_data:
        raise ValueError("User data required")
    # ... validation logic
    return ValidatedUserData(user_data)

def _process_validated_data(validated_data: ValidatedUserData) -> ProcessedData:
    """Process validated user data."""
    # ... processing logic
    return ProcessedData(result)

def _format_processed_data(processed_data: ProcessedData) -> ProcessedUser:
    """Format processed data for output."""
    # ... formatting logic
    return ProcessedUser(formatted)
```

#### Extract Class Refactoring
```python
# Before: Function with many parameters
def calculate_shipping(
    weight, dimensions, origin, destination, 
    shipping_type, insurance, express, 
    customer_tier, discounts
):
    # Complex calculation logic
    pass

# After: Extract to dedicated class
class ShippingCalculator:
    """Handles shipping cost calculations."""
    
    def __init__(self, origin: Address, destination: Address):
        self.origin = origin
        self.destination = destination
    
    def calculate(self, package: Package, options: ShippingOptions) -> ShippingCost:
        """Calculate shipping cost for package with options."""
        base_cost = self._calculate_base_cost(package)
        modifiers = self._apply_modifiers(base_cost, options)
        return ShippingCost(base_cost + modifiers)
```

#### Simplify Conditional Logic
```python
# Before: Complex nested conditions
def determine_user_access(user, resource, action):
    if user:
        if user.is_active:
            if user.role == 'admin':
                return True
            elif user.role == 'moderator':
                if action in ['read', 'update']:
                    return True
                else:
                    return False
            elif user.role == 'user':
                if action == 'read' and resource.is_public:
                    return True
                else:
                    return False
        else:
            return False
    else:
        return False

# After: Early returns and clear logic
def determine_user_access(user: User, resource: Resource, action: str) -> bool:
    """Determine if user has access to perform action on resource."""
    if not user or not user.is_active:
        return False
    
    if user.role == 'admin':
        return True
    
    if user.role == 'moderator':
        return action in ['read', 'update']
    
    if user.role == 'user':
        return action == 'read' and resource.is_public
    
    return False
```

### 3.2 Apply Design Patterns

#### Replace Magic Numbers with Constants
```python
# Before: Magic numbers scattered through code
def process_payment(amount):
    if amount > 10000:  # What is 10000?
        fee = amount * 0.025  # What is 0.025?
    else:
        fee = amount * 0.03   # What is 0.03?
    return amount + fee

# After: Named constants
class PaymentConstants:
    LARGE_PAYMENT_THRESHOLD = 10000
    LARGE_PAYMENT_FEE_RATE = 0.025
    STANDARD_FEE_RATE = 0.03

def process_payment(amount: Decimal) -> Decimal:
    """Process payment and calculate fees."""
    if amount > PaymentConstants.LARGE_PAYMENT_THRESHOLD:
        fee_rate = PaymentConstants.LARGE_PAYMENT_FEE_RATE
    else:
        fee_rate = PaymentConstants.STANDARD_FEE_RATE
    
    fee = amount * fee_rate
    return amount + fee
```

#### Remove Code Duplication
```python
# Before: Duplicated validation logic
def create_user(user_data):
    if not user_data.email or '@' not in user_data.email:
        raise ValidationError("Invalid email")
    if not user_data.password or len(user_data.password) < 8:
        raise ValidationError("Password too short")
    # ... create user

def update_user(user_id, user_data):
    if not user_data.email or '@' not in user_data.email:
        raise ValidationError("Invalid email")
    if not user_data.password or len(user_data.password) < 8:
        raise ValidationError("Password too short")
    # ... update user

# After: Extracted common validation
def _validate_user_data(user_data: UserData) -> None:
    """Validate user data common to create and update operations."""
    if not user_data.email or '@' not in user_data.email:
        raise ValidationError("Invalid email")
    if not user_data.password or len(user_data.password) < 8:
        raise ValidationError("Password too short")

def create_user(user_data: UserData) -> User:
    """Create new user after validation."""
    _validate_user_data(user_data)
    # ... create user

def update_user(user_id: int, user_data: UserData) -> User:
    """Update existing user after validation."""
    _validate_user_data(user_data)
    # ... update user
```

## ✅ Phase 4: Validation and Testing

### 4.1 Run All Existing Tests
```bash
# Ensure all existing tests still pass
python scripts/testing/adaptive_test_runner.py --all

# Run specific tests for refactored area
python -m pytest tests/unit/test_refactored_module.py -v

# Check integration tests
python -m pytest tests/integration/ -k "refactored_functionality"
```

### 4.2 Verify Performance
```bash
# Run performance tests if applicable
python scripts/testing/performance_benchmark.py

# Compare with baseline measurements
# Ensure refactoring didn't degrade performance
```

### 4.3 Quality Checks
```bash
# Run linting and type checking
ruff check . && mypy src/ tests/

# Check test coverage is maintained or improved
python -m pytest --cov=src/ice_t --cov-report=term-missing
```

## 📊 Phase 5: Documentation and Cleanup

### 5.1 Update Documentation
- Update docstrings for modified functions
- Add comments explaining complex refactored logic
- Update any architectural documentation
- Document new patterns or conventions used

### 5.2 Clean Up Test Code
```python
# Remove obsolete characterization tests if no longer needed
# Update test names to reflect new structure
# Add tests for new extracted methods/classes

def test_validate_user_data():
    """Test the new extracted validation function."""
    valid_data = UserData(email="test@example.com", password="securepass123")
    # Should not raise
    _validate_user_data(valid_data)
    
    invalid_data = UserData(email="invalid", password="short")
    with pytest.raises(ValidationError):
        _validate_user_data(invalid_data)
```

## 🔄 Common Refactoring Patterns

### 1. Function Decomposition
- Split large functions into smaller, focused ones
- Each function should do one thing well
- Use descriptive names for extracted functions

### 2. Class Extraction
- Group related data and behavior into classes
- Use dependency injection for better testability
- Follow single responsibility principle

### 3. Conditional Simplification
- Use early returns to reduce nesting
- Extract complex conditions into well-named methods
- Consider polymorphism for type-based conditions

### 4. Data Structure Improvement
- Replace primitive obsession with value objects
- Use enums for fixed sets of values
- Introduce DTOs for data transfer

### 5. Error Handling Improvement
- Replace generic exceptions with specific ones
- Add proper error messages and context
- Use structured error handling patterns

## 🚨 Refactoring Safety Guidelines

### Red Flags - Stop and Reconsider
- Tests are failing after refactoring
- Performance significantly degraded
- External APIs or interfaces changed unexpectedly
- Code became more complex instead of simpler

### Best Practices
1. **Small Steps**: Make one change at a time
2. **Test Frequently**: Run tests after each change
3. **Preserve Behavior**: Don't change functionality while refactoring
4. **Document Reasons**: Explain why the refactoring improves the code
5. **Get Feedback**: Have changes reviewed if possible

## 📝 Refactoring PR Template
```markdown
## ♻️ Refactoring: [Brief Description]

### Motivation
- **Problem**: [What made the code hard to work with]
- **Goal**: [What improvement this refactoring achieves]

### Changes
- **Extracted Methods**: [List of new methods/functions]
- **Simplified Logic**: [Areas where complexity was reduced]
- **Improved Names**: [Better variable/function names]
- **Removed Duplication**: [Code that was deduplicated]

### Verification
- [ ] All existing tests pass
- [ ] Performance maintained or improved
- [ ] Code coverage maintained or improved
- [ ] Linting and type checking pass
- [ ] Documentation updated

### Before/After Metrics
- **Cyclomatic Complexity**: [Before] → [After]
- **Function Length**: [Before] → [After]
- **Test Coverage**: [Before] → [After]
```

## 🎯 Success Criteria

A successful refactoring should:
- ✅ Maintain all existing functionality
- ✅ Improve code readability and maintainability
- ✅ Reduce complexity without adding confusion
- ✅ Maintain or improve performance
- ✅ Keep or increase test coverage
- ✅ Follow project architectural patterns
- ✅ Make future changes easier to implement 