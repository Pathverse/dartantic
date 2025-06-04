# dartantic

A powerful model validation and processing system using decorators, inspired by [python pydantic](https://docs.pydantic.dev/latest/). Makes data classes and validation easy in Dart.

## Quick Start

1. Add to your `pubspec.yaml`:
```yaml
dependencies:
  dartantic: ^0.1.2
```

2. Create your model:
```dart
@dttModel
class User {
  final String name;
  final int age;
  final String? email;

  const User({required this.name, required this.age, this.email});

  // Optional: Add custom validation
  static bool _dttvalidate_age(int age) => age >= 0 && age <= 150;

  // Optional: Add preprocessing
  static String _dttpreprocess_name(String name) => name.trim();
}
```

3. Generate code:
```bash
# Generate model validation code
dart run dartantic model

# Generate BLoC code (if using @dttBloc)
dart run dartantic bloc
```

4. Use your model:
```dart
// Create with validation
final user = User.dttCreate(
  name: 'John Doe',
  age: 30,
  email: 'john@example.com',
);

// Convert to/from Map
final map = user.dttToMap();
final user2 = User.dttFromMap(map);

// Validate data
final errors = user.dttValidate();
if (errors.isEmpty) {
  print('Data is valid!');
}
```

## Usage Guide

### CLI Commands

#### Model Generation
```bash
# Generate model validation code for all files
dart run dartantic model

# Generate model validation code for a specific directory
dart run dartantic model lib/models

# Generate model validation code and BLoC code
dart run dartantic model --bloc

# Force regenerate all model files
dart run dartantic model --force

# Enable verbose output
dart run dartantic model --verbose
```

#### BLoC Generation
```bash
# Generate BLoC code for all files with @dttBloc
dart run dartantic bloc

# Generate BLoC code for a specific directory
dart run dartantic bloc lib/features/auth

# Force regenerate all BLoC files
dart run dartantic bloc --force

# Enable verbose output
dart run dartantic bloc --verbose
```

#### Common Options
- `--verbose` or `-v`: Enable detailed output
- `--force` or `-f`: Force regenerate all files
- `--bloc` or `-b`: Generate BLoC code along with models (model command only)

Note: BLoC generation will skip files that already have generated code unless `--force` is used.

### Basic Model Usage
```dart
@dttModel
class User {
  final String name;
  final int age;
  final String? email;

  const User({required this.name, required this.age, this.email});
}

// Create and validate
final user = User.dttCreate(
  name: 'John Doe',
  age: 30,
  email: 'john@example.com',
);

// Convert to Map
final map = user.dttToMap();
// {
//   'name': 'John Doe',
//   'age': 30,
//   'email': 'john@example.com'
// }

// Create from Map with validation
final user2 = User.dttFromMap(map);
```

### Model with Validation
```dart
@dttModel
class User {
  final String name;
  final int age;
  final String? email;

  const User({required this.name, required this.age, this.email});

  // Custom validation
  static bool _dttvalidate_age(int age) => age >= 0 && age <= 150;

  // Custom preprocessing
  static String _dttpreprocess_name(String name) => name.trim();
}

// Validation will fail for invalid age
try {
  final user = User.dttCreate(
    name: 'John Doe',
    age: 200,  // Invalid age
    email: 'john@example.com',
  );
} catch (e) {
  print('Validation failed: $e');
}

// Name will be trimmed
final user = User.dttCreate(
  name: '  John Doe  ',  // Will be trimmed
  age: 30,
  email: 'john@example.com',
);
print(user.name);  // 'John Doe'
```

### BLoC Integration
```dart
@dttModel
@dttBloc
class User {
  final String name;
  final int age;
  final String? email;

  const User({required this.name, required this.age, this.email});
}

// Generate BLoC code
// dart run dartantic:dtt bloc

// Use the generated BLoC
final cubit = DttBlocUserCubit();

// Load data with validation
await cubit.loadData({
  'name': 'John Doe',
  'age': 30,
  'email': 'john@example.com',
});

// Update fields with validation
cubit.updateName('Jane Doe');
cubit.updateAge(25);

// Save data
await cubit.saveData();

// Reset state
cubit.reset();
```

### Available Features

#### 1. Model Generation
- Automatic validation
- Custom validation methods
- Preprocessing hooks
- Type safety
- Null safety
- Nested model support

#### 2. BLoC Generation
- State management
- Field updates with validation
- Data loading with validation
- Save operations
- Error handling
- Loading states

#### 3. Validation
- Field-level validation
- Custom validation methods
- Preprocessing hooks
- Type safety
- Nullable field support
- Nested model validation

## Development

For developers contributing to dartantic, see [CONTRIBUTING.md](CONTRIBUTING.md).

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
