# dartantic

dartantic is a library trying to make data classes and validation easy, inspired by [python pydantic](https://docs.pydantic.dev/latest/).

It uses source generation to create data classes, validation functions, and BLoC state management.

## Features

### 1. Model Generation
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
```

### 2. BLoC Generation
```dart
@dttModel
@dttBloc
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
```

Generates:
- State classes (Initial, Loading, Error, StateData)
- Event classes (Update, Load, Save, Reset, Validate)
- Cubit class with:
  - Field update methods with validation
  - Data loading with validation
  - Save operation with validation
  - State management

### 3. Validation
- Field-level validation
- Custom validation methods
- Preprocessing hooks
- Type safety
- Nullable field support

### 4. Code Generation
- Uses Abstract Syntax Generator (ASG) for declarative code generation
- Generates part files (.dartantic.g.dart, .bloc.g.dart)
- Maintains clean separation between generated and user code

### 5. State Management
- Built-in BLoC pattern implementation
- Automatic state transitions
- Validation integration
- Error handling
- Type-safe state updates

## Usage

### Basic Model
```dart
@dttModel
class User {
  final String name;
  final int age;
  final String? email;

  const User({required this.name, required this.age, this.email});
}
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
```

### BLoC Integration
```dart
@dttModel
@dttBloc
class User {
  // ... model definition ...

  // Generated BLoC usage:
  final cubit = DttBlocUserCubit();
  
  // Load data
  await cubit.loadData({
    'name': 'John Doe',
    'age': 30,
    'email': 'john@example.com',
  });

  // Update fields
  cubit.updateName('Jane Doe');
  cubit.updateAge(25);

  // Save data
  await cubit.saveData();

  // Reset state
  cubit.reset();
}
```

## Development

### Code Generation
Run the code generator:
```bash
dart run build_runner build
```

### BLoC Generation
Run the BLoC generator:
```bash
dart run lib/tools/generate_blocs.dart
```

## Testing
The project includes comprehensive tests demonstrating:
- Model validation
- BLoC state transitions
- Error handling
- Field updates
- Data loading and saving

Run tests with:
```bash
flutter test
```

## Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

## License
This project is licensed under the MIT License - see the LICENSE file for details.
