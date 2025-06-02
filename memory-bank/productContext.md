# Product Context

## Problem Statement
Dart developers need a simple, type-safe way to:
1. Create data classes with validation
2. Manage state in Flutter applications
3. Reduce boilerplate code
4. Ensure data integrity
5. Follow best practices

## Solution
dartantic provides:
1. Easy data class creation with validation
2. Built-in BLoC state management
3. Source code generation
4. Type safety
5. Familiar API for Python developers

## User Experience Goals

### 1. Developer Experience
- **Simple API**
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

- **Clear Error Messages**
  ```dart
  // Invalid age
  cubit.updateAge(200);
  // Error: "Invalid age: 200"
  ```

- **IDE Support**
  - Code completion
  - Type checking
  - Error highlighting
  - Navigation

### 2. State Management
- **Intuitive BLoC Pattern**
  ```dart
  @dttModel
  @dttBloc
  class User {
    // ... model definition ...
  }

  // Usage
  final cubit = DttBlocUserCubit();
  await cubit.loadData(data);
  cubit.updateAge(25);
  await cubit.saveData();
  ```

- **Predictable State Transitions**
  ```dart
  // State flow
  Initial -> Loading -> StateData
  Initial -> Loading -> Error
  StateData -> Loading -> StateData
  StateData -> Loading -> Error
  ```

### 3. Validation
- **Field-Level Validation**
  ```dart
  // Age validation
  static bool _dttvalidate_age(int age) => age >= 0 && age <= 150;

  // Name preprocessing
  static String _dttpreprocess_name(String name) => name.trim();
  ```

- **Type Safety**
  - Compile-time checks
  - Null safety
  - Custom validation
  - Error handling

## Target Users

### 1. Flutter Developers
- Building data-driven apps
- Need state management
- Want type safety
- Prefer clean code

### 2. Python Developers
- Familiar with pydantic
- Learning Dart/Flutter
- Want similar API
- Need validation

### 3. Enterprise Teams
- Need maintainable code
- Want type safety
- Follow best practices
- Use state management

## Use Cases

### 1. Form Validation
```dart
@dttModel
@dttBloc
class UserForm {
  final String name;
  final int age;
  final String? email;

  const UserForm({required this.name, required this.age, this.email});

  // Validation
  static bool _dttvalidate_age(int age) => age >= 0 && age <= 150;
  static String _dttpreprocess_name(String name) => name.trim();
}

// Usage
final formCubit = DttBlocUserFormCubit();
formCubit.updateName('John Doe');
formCubit.updateAge(25);
await formCubit.saveData();
```

### 2. API Models
```dart
@dttModel
class ApiResponse {
  final int status;
  final String message;
  final User? data;

  const ApiResponse({
    required this.status,
    required this.message,
    this.data,
  });
}

// Usage
final response = ApiResponse.fromMap(json);
if (response.status == 200) {
  final user = response.data;
  // Use validated user data
}
```

### 3. State Management
```dart
@dttModel
@dttBloc
class UserProfile {
  final String name;
  final int age;
  final String? email;
  final List<String> preferences;

  const UserProfile({
    required this.name,
    required this.age,
    this.email,
    required this.preferences,
  });
}

// Usage
final profileCubit = DttBlocUserProfileCubit();
await profileCubit.loadData(userData);
profileCubit.updatePreferences(['dark_mode', 'notifications']);
await profileCubit.saveData();
```

## Success Metrics

### 1. Developer Experience
- Easy to learn
- Clear documentation
- Good error messages
- IDE support

### 2. Code Quality
- Type safety
- Validation
- State management
- Error handling

### 3. Performance
- Fast code generation
- Efficient validation
- Minimal runtime overhead
- Quick state transitions

### 4. Adoption
- Active community
- Regular updates
- Good documentation
- Example gallery 