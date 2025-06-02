# Technical Context

## Technologies Used

### Core Technologies
- Dart SDK (latest stable)
- Flutter SDK (for testing)
- build_runner (code generation)
- bloc (state management)
- equatable (state comparison)

### Development Tools
- VS Code / Android Studio
- Dart Analyzer
- Flutter Test
- Git (version control)

## Development Setup

### Required Tools
1. Dart SDK
2. Flutter SDK (for testing)
3. build_runner
4. bloc package
5. equatable package

### Project Structure
```
dartantic/
├── lib/
│   ├── asg/
│   │   └── asg.dart                    # Abstract Syntax Generator - Core code generation utilities
│   │
│   ├── blocGen/
│   │   └── annotations/
│   │       └── bloc.dart               # BLoC generation annotations (@dttBloc) and related metadata
│   │
│   ├── core/
│   │   ├── exception.dart              # Custom exceptions (e.g., DttValidationError)
│   │   └── metacls.dart               # Base metadata classes for model and field information
│   │
│   ├── modelGen/
│   │   ├── annotations/
│   │   │   ├── annotations.dart        # Model generation annotations (@dttModel) and base classes
│   │   │   └── validators.dart         # Built-in validators (@DttvMinLength, @DttvNotNull, etc.)
│   │   │
│   │   ├── generators/
│   │   │   ├── create_method.dart      # Generates dttCreate method for model instantiation
│   │   │   ├── frommap_method.dart     # Generates dttFromMap for deserialization
│   │   │   ├── metadata.dart           # Generates model and field metadata
│   │   │   ├── postprocess_method.dart # Generates dttPostprocess for post-validation
│   │   │   ├── preprocess_method.dart  # Generates dttPreprocess for input cleaning
│   │   │   ├── tomap_method.dart       # Generates dttToMap for serialization
│   │   │   └── validate_method.dart    # Generates dttValidate for validation
│   │   │
│   │   ├── utils/
│   │   │   ├── code_utils.dart         # Shared code generation utilities
│   │   │   └── field_utils.dart        # Field metadata and type handling utilities
│   │   │
│   │   └── main.dart                   # Main model generator entry point
│   │
│   └── dartantic.dart                  # Library entry point, exports public API
│
├── test/
│   ├── z_blocgen/                      # BLoC generation tests
│   │   └── zbloc_test.dart
│   └── z_modelgen/                     # Model generation tests
│       └── zmodel_test.dart
│
├── tool/
│   └── generate_blocs.dart             # BLoC code generator script

```

### Dependencies
```yaml
dependencies:
  bloc: ^8.1.3
  equatable: ^2.0.5

dev_dependencies:
  build_runner: ^2.4.7
  test: ^1.24.9
  flutter_test:
    sdk: flutter
```

## Code Generation

### Model Generation
- Triggered by `@dttModel` annotation
- Generates `.dartantic.g.dart` files
- Creates data classes with validation
- Supports custom validation methods

### BLoC Generation
- Triggered by `@dttBloc` annotation (case-insensitive)
- Generates `.bloc.g.dart` files
- Creates state management code
- Integrates with validation system
- Features:
  - Case-insensitive annotation detection
  - Proper directory handling
  - Enhanced logging
  - File scanning statistics
  - Detailed error reporting

### Generation Commands
```bash
# Generate model code
dart run build_runner build

# Generate BLoC code
dart run dartantic gen --bloc --force
```

### Directory Management
```dart
// Store original directory
final originalDir = Directory.current;
try {
  // Change to project directory
  Directory.current = projectDir;
  // Perform operations
} finally {
  // Always restore original directory
  Directory.current = originalDir;
}
```

### Annotation Detection
```dart
// Case-insensitive annotation detection
if (RegExp(r'@dttbloc', caseSensitive: false).hasMatch(content)) {
  if (RegExp(r'@dttbloc\s*\(\)|@dttbloc\s*$|@dttbloc\s*[;{]', 
      caseSensitive: false).hasMatch(content)) {
    // Process valid annotation
  }
}
```

### File Processing
```dart
// Track scanning statistics
var scannedFiles = 0;
var foundFiles = 0;
var generatedFiles = 0;

// Process files with detailed logging
print('📂 Scanning directory: ${dir.path}');
print('🔍 Processing file: ${path.relative(filePath)}');
print('📊 Summary: Scanned $scannedFiles, Found $foundFiles, Generated $generatedFiles');
```

## Testing

### Test Types
1. Unit Tests
   - Model validation
   - Field preprocessing
   - State transitions
   - Error handling

2. Integration Tests
   - BLoC lifecycle
   - State management
   - Data loading/saving

### Running Tests
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/z_blocgen/zbloc_test.dart
```

## Technical Constraints

### Code Generation
- Must work with Dart's build system
- Must generate valid Dart code
- Must handle circular dependencies
- Must support custom annotations
- Must handle directory changes correctly
- Must use case-insensitive annotation detection

### State Management
- Must follow BLoC pattern
- Must handle async operations
- Must validate state transitions
- Must support error states
- Must maintain directory state
- Must provide detailed logging

### Validation
- Must be type-safe
- Must support custom rules
- Must handle null safety
- Must provide clear errors
- Must support case-insensitive annotations
- Must validate annotation format

## Tool Usage Patterns

### Model Definition
```dart
@dttModel
class User {
  final String name;
  final int age;
  final String? email;

  const User({required this.name, required this.age, this.email});

  // Custom validation
  static bool _dttvalidate_age(int age) => age >= 0 && age <= 150;
}
```

### BLoC Integration
```dart
@dttModel
@DttBloc  // Case-insensitive annotation
class User {
  // ... model definition ...
}

// Usage
final cubit = DttBlocUserCubit();
await cubit.loadData(data);
```

### Testing
```dart
void main() {
  group('UserCubit', () {
    test('validates age correctly', () {
      final cubit = DttBlocUserCubit();
      cubit.updateAge(200);
      expect(cubit.state, isA<DttBlocUserError>());
    });

    test('handles directory changes correctly', () {
      // Test directory handling
    });

    test('detects annotations case-insensitively', () {
      // Test annotation detection
    });
  });
}
```

## Recent Architectural Changes (2025-06)
- ASG (lib/asg/asg.dart) is now the foundation for all code generation
- BLoC generator improvements:
  - Case-insensitive annotation detection
  - Proper directory handling
  - Enhanced logging
  - File scanning statistics
- Project structure:
  - `lib/blocGen/generators/` contains modular generator files
  - `lib/tools/generate_blocs.dart` is the entry point
  - Directory handling is robust and logged
  - Annotation detection is case-insensitive
- This architecture enables:
  - Reliable directory management
  - Flexible annotation formats
  - Detailed logging and debugging
  - Clear error reporting

// ... existing code ... 