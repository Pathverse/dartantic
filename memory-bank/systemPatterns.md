# System Patterns

## Architecture Overview

### Code Generation Pipeline
```mermaid
graph TD
    A[Source Code] --> B[Annotation Processing]
    B --> C[Model Analysis]
    C --> D[Code Generation]
    D --> E[Generated Code]
    
    subgraph "Model Generation"
        B --> F[Extract Fields]
        B --> G[Find Validation Methods]
        F --> H[Generate Data Class]
        G --> I[Generate Validation]
    end
    
    subgraph "BLoC Generation"
        B --> J[Extract BLoC Annotation]
        J --> K[Generate States]
        J --> L[Generate Events]
        J --> M[Generate Cubit]
    end
```

## Design Patterns

### 1. Code Generation
- **Annotation Processing**
  - `@dttModel` for model generation
  - `@dttBloc` for BLoC generation
  - Custom validation methods

- **State Management**
  - BLoC pattern implementation
  - State transitions
  - Event handling
  - Error management

### 2. Validation System
- **Field Validation**
  ```dart
  static bool _dttvalidate_age(int age) => age >= 0 && age <= 150;
  ```

- **Preprocessing**
  ```dart
  static String _dttpreprocess_name(String name) => name.trim();
  ```

- **State Validation**
  ```dart
  bool validate() {
    if (state is! DttBlocUserStateData) return false;
    final data = state as DttBlocUserStateData;
    return User._dttvalidate_age(data.age);
  }
  ```

### 3. State Management
- **State Classes**
  ```dart
  abstract class DttBlocUserState extends Equatable {
    const DttBlocUserState();
  }

  class DttBlocUserStateData extends DttBlocUserState {
    final String name;
    final int age;
    final String? email;
    // ...
  }
  ```

- **Event Classes**
  ```dart
  abstract class DttBlocUserEvent extends Equatable {
    const DttBlocUserEvent();
  }

  class DttBlocUserUpdateAge extends DttBlocUserEvent {
    final int age;
    const DttBlocUserUpdateAge(this.age);
  }
  ```

- **Cubit Implementation**
  ```dart
  class DttBlocUserCubit extends Cubit<DttBlocUserState> {
    void updateAge(int age) {
      if (!User._dttvalidate_age(age)) {
        emit(DttBlocUserState.error('Invalid age: $age'));
        return;
      }
      // ...
    }
  }
  ```

## Component Relationships

### 1. Model to BLoC
```mermaid
graph LR
    A[Model Class] --> B[Generated Data Class]
    A --> C[Validation Methods]
    B --> D[State Data]
    C --> E[State Validation]
    D --> F[Cubit]
    E --> F
```

### 2. State Management Flow
```mermaid
graph TD
    A[Event] --> B[Cubit]
    B --> C{Validation}
    C -->|Valid| D[Update State]
    C -->|Invalid| E[Error State]
    D --> F[New State]
    E --> F
```

## Critical Implementation Paths

### 1. Model Generation
1. Parse source code
2. Extract model metadata
3. Generate data class
4. Generate validation methods
5. Generate serialization

### 2. BLoC Generation
1. Parse BLoC annotation
2. Generate state classes
3. Generate event classes
4. Generate cubit implementation
5. Integrate validation

### 3. State Transitions
1. Event received
2. Validation check
3. State update
4. Error handling
5. State emission

## Key Technical Decisions

### 1. Code Generation
- Use build_runner for code generation
- Generate part files for clean separation
- Support custom validation methods
- Maintain type safety

### 2. State Management
- Implement BLoC pattern
- Use Equatable for state comparison
- Support async operations
- Handle validation errors

### 3. Validation
- Field-level validation
- Custom validation methods
- Preprocessing hooks
- Type safety

## Implementation Guidelines

### 1. Model Definition
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

### 2. BLoC Integration
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

### 3. Testing
```dart
void main() {
  group('UserCubit', () {
    test('validates age correctly', () {
      final cubit = DttBlocUserCubit();
      cubit.updateAge(200);
      expect(cubit.state, isA<DttBlocUserError>());
    });
  });
}
```

## Architecture Overview - MODULAR & PRODUCTION READY

### 1. Modular Code Generation System ✅
- **Separation of Concerns**: Each generator handles one method type
- **Utility-Based Patterns**: Shared code generation helpers
- **Zero Duplication**: Common logic extracted to utilities
- **Clean Orchestration**: Main generator coordinates focused modules

### 2. Annotation-Based Validation ✅
- **Direct Constant Processing**: Extract values from annotation constants
- **Type-Specific Logic**: Different handling per annotation type
- **Rich Error Context**: Field-specific error messages
- **No Runtime Overhead**: All validation code generated at build time

### 3. Nested Model System ✅
- **Recursive Processing**: Nested models use their own validation pipeline
- **Map-Based Communication**: Type-safe communication via processed maps
- **Metadata-Driven**: Compile-time nested model detection
- **Optional Handling**: Proper null safety for optional nested models

## Modular Architecture - PROVEN DESIGN

### File Structure (Post-Refactoring)
```
lib/core/gen/
├── main.dart (2.3KB)           # Clean orchestration
├── generators/                  # Focused method generators
│   ├── create_method.dart      # dttCreate generation
│   ├── preprocess_method.dart  # dttPreprocess generation
│   ├── validate_method.dart    # dttValidate generation
│   ├── postprocess_method.dart # dttPostprocess generation
│   ├── frommap_method.dart     # dttFromMap generation
│   ├── tomap_method.dart       # dttToMap generation
│   └── metadata.dart           # Model metadata generation
└── utils/                      # Shared utilities
    ├── field_utils.dart        # Field operations and metadata
    └── code_utils.dart         # Code generation patterns
```

### Key Design Patterns - PROVEN SUCCESSFUL

#### 1. Single Responsibility Generators
```dart
class CreateMethodGenerator {
  static ASG generate(ClassElement element, Map<String, dynamic> fieldMetaDict) {
    // Only handles dttCreate method generation
    final parameters = CodeUtils.generateCreateMethodParameters(fieldMetaDict);
    final valueAssignments = CodeUtils.generateValueAssignments(fieldMetaDict);
    // Clean, focused responsibility
  }
}
```

#### 2. Utility-Based Code Generation
```dart
class CodeUtils {
  // Reusable patterns across all generators
  static List<String> generateConditionalValidation(String field, String condition, String error);
  static String generateNestedSerialization(String subModel, String field, bool isOptional);
  static ASG createMethod({required String name, ...});
}
```

#### 3. Field Metadata as Source of Truth
```dart
class FieldUtils {
  // All field operations go through metadata validation
  static Map<String, dynamic> generateFieldMetaDict(ClassElement element, Map<String, ClassElement> models);
  static bool fieldExistsInMeta(String fieldName, Map<String, dynamic> fieldMetaDict);
  static String? extractFieldName(String methodName, String prefix);
}
```

## Component Relationships - WELL-DEFINED

### 1. Main Generator → Modular Generators
- **Orchestration**: Main generator coordinates all method generators
- **Field Metadata**: Single fieldMetaDict passed to all generators
- **ASG Sources**: Each generator returns ASG source code
- **Assembly**: Metadata generator assembles final mixin

### 2. Generators → Utilities
- **Code Patterns**: Generators use utility methods for common patterns
- **Field Operations**: All field access goes through FieldUtils
- **Validation**: Shared validation patterns in CodeUtils
- **Type Safety**: Utilities handle type-specific logic

### 3. Annotation Processing → Code Generation
- **Direct Processing**: Annotations processed as constant values
- **Type Dispatch**: Different logic per annotation type
- **Parameter Extraction**: Values extracted from annotation fields
- **Error Context**: Field names included in generated error messages

## Implementation Guidelines - PROVEN PRACTICES

### 1. Code Generation Excellence
- **ASG-First**: All code generation uses ASG for consistency
- **Utility-Based**: Extract common patterns to utilities
- **Metadata-Driven**: Field metadata is single source of truth
- **Error Context**: Include field names in all error messages

### 2. Validation Processing
- **Direct Annotation Processing**: Process annotation constants directly
- **Pipeline Architecture**: preprocess → validate → postprocess
- **Static Method Detection**: Regex-based with metadata validation
- **Type Safety**: Compile-time type checking and casting

### 3. Nested Model Handling
- **Recursive Processing**: Use target model's own validation pipeline
- **Map Communication**: Pass processed maps between model levels
- **Optional Safety**: Proper null handling for optional nested models
- **Metadata Detection**: Compile-time subModel detection

## Validation Patterns - FULLY IMPLEMENTED

### Annotation-Based Validation ✅
```dart
// IN: Annotation constants
@DttvMinLength(5)  // obj.getField('minLength').toIntValue() = 5
@DttvMaxLength(50) // obj.getField('maxLength').toIntValue() = 50

// OUT: Generated validation code
if (values['email'] != null && values['email'].length < 5) {
  throw DttValidationError('email', 'email must be at least 5 characters');
}
```

### Static Method Validation ✅
```dart
// IN: Static method detection
static bool _dttvalidate_email(String email, Map<String, dynamic> values) {
  return email.contains('@') && email.contains('.');
}

// OUT: Generated validation call
if (values['email'] != null && !User._dttvalidate_email(values['email'], values)) {
  throw DttValidationError('email', 'email failed custom validation');
}
```

### Nested Model Processing ✅
```dart
// IN: Nested model field
final User user; // Detected as subModel: 'User'

// OUT: Generated serialization
'user': _$UserMixin.dttToMap(obj.user),

// OUT: Generated deserialization
'user': _$UserMixin.dttFromMap(map['user'] as Map<String, dynamic>),
```

## Error Handling Patterns - COMPREHENSIVE

### 1. Validation Errors ✅
- **Field Context**: Every error includes field name
- **Descriptive Messages**: Human-readable error descriptions
- **Type-Specific**: Different messages per validation type
- **Custom Integration**: Static method errors use same pattern

### 2. Generation Safety ✅
- **Metadata Validation**: Field existence checked before processing
- **Warning Comments**: Generated for invalid field references
- **Exception Handling**: Try-catch around annotation processing
- **Graceful Degradation**: Continue generation with warnings

### 3. Type Safety ✅
- **Compile-Time Checks**: All type relationships validated at build time
- **Casting Safety**: Generated code includes proper type casting
- **Null Safety**: Optional fields handled correctly throughout
- **Generic Patterns**: Utilities work with any model type

## Performance Patterns - OPTIMIZED

### 1. Build-Time Generation ✅
- **Zero Runtime Overhead**: All validation logic generated at compile time
- **Direct Code**: No reflection or dynamic dispatch in generated code
- **Efficient Patterns**: Generated code uses optimal Dart patterns
- **Memory Efficient**: Minimal object creation in validation pipeline

### 2. Modular Benefits ✅
- **Incremental Builds**: Only changed generators recompile
- **Parallel Development**: Team can work on different generators
- **Easy Testing**: Test individual generators in isolation
- **Simple Maintenance**: Changes isolated to specific modules

## Critical Success Patterns - PROVEN & STABLE

### ✅ WORKING APPROACHES (MAINTAIN THESE)

#### 1. Direct Annotation Processing
```dart
// Extract values directly from annotation constants
final minLength = obj.getField('minLength')?.toIntValue() ?? 0;
// Generate code immediately, no validator instantiation needed
```

#### 2. Field Metadata as Source of Truth
```dart
// All field operations validate against metadata
if (FieldUtils.fieldExistsInMeta(fieldName, fieldMetaDict)) {
  // Process field
} else {
  // Generate warning
}
```

#### 3. Modular Generator Pattern
```dart
// Each generator has single responsibility
class ValidateMethodGenerator {
  static ASG generate(ClassElement element, Map<String, dynamic> fieldMetaDict) {
    // Only handles validation generation
  }
}
```

### ❌ FAILED APPROACHES (NEVER RETRY)

#### 1. Validator Instance Access
- `obj.getField('instance')` - Always returns null
- `validator.asg(context)` - Validator instances not accessible
- `params` getter access - Not available during build time

#### 2. Constructor Parameter Access
- Direct constructor argument access - Not supported by analyzer
- Field reflection on annotation objects - Does not work
- Dynamic parameter discovery - Unreliable and complex

#### 3. Hardcoded Type Checking
- Checking specific validator names - Breaks extensibility
- Switch statements on type names - Not maintainable
- Validator-specific parameter names - Creates coupling

## Architecture Benefits - PROVEN VALUE

### 1. Maintainability Excellence
- **85% Code Reduction**: main.dart from 16KB to 2.3KB
- **Single Responsibility**: Each file has one clear purpose
- **Zero Duplication**: Common patterns extracted to utilities
- **Easy Extension**: Adding features requires only new generator

### 2. Development Velocity
- **Parallel Work**: Team can work on different generators
- **Fast Testing**: Test individual components in isolation
- **Simple Debugging**: Issues isolated to specific modules
- **Clean Dependencies**: Clear relationships between components

### 3. Production Quality
- **High Test Coverage**: 19 tests covering all features
- **Performance Optimized**: Generated code is efficient
- **Type Safe**: Compile-time validation with full type safety
- **Developer Experience**: Clean API matching Pydantic patterns

## Future Extension Patterns

### Adding New Validators
1. **Extend ValidateMethodGenerator**: Add new annotation type handling
2. **Update CodeUtils**: Add new validation pattern if needed
3. **No Other Changes**: Existing architecture supports new validators

### Adding New Methods
1. **Create New Generator**: Follow existing generator pattern
2. **Add to Main**: Include in methodSources array
3. **Reuse Utilities**: Leverage existing field and code utilities

### Adding New Features
1. **Assess Scope**: Determine if it's method-level or system-level
2. **Follow Patterns**: Use established utility and generator patterns
3. **Maintain Separation**: Keep concerns cleanly separated

## Code Generation
1. Model Generation
   - Uses build_runner for code generation
   - Generates `.dartantic.g.dart` files with model metadata
   - Follows Pydantic-like patterns for validation and serialization

2. Bloc Generation
   - Standalone generator (`lib/tools/generate_blocs.dart`)
   - Uses regex to extract metadata from `.dartantic.g.dart` files
   - Generates `.bloc.g.dart` files as part files
   - Follows consistent naming: `DttBloc{ModelName}{Type}`
   - Maintains model validation in original class

## Design Patterns
1. Model Pattern
   - Immutable data classes
   - Validation and preprocessing methods
   - Mixin-based code generation
   - Part file organization

2. Bloc Pattern
   - State management using BLoC pattern
   - Cubit-based implementation
   - State classes: Initial, Loading, Error, Data
   - Event classes for updates and actions
   - Validation integration with model methods

## Component Relationships
1. Model to Bloc
   - Model provides validation and preprocessing
   - Bloc uses model methods for data integrity
   - Part file relationship maintains access to model methods
   - Generated code follows model's field structure

2. Generated Code Organization
   - `.dartantic.g.dart`: Model metadata and mixins
   - `.bloc.g.dart`: State management code
   - Original file: Model definition and annotations

## Critical Paths
1. Model Generation
   - Annotation processing
   - Metadata generation
   - Mixin implementation

2. Bloc Generation
   - Metadata extraction
   - State/Event class generation
   - Cubit implementation
   - Validation integration

## ASG-Driven Modular Code Generation (2025-06)
- All code generation (model, validation, BLoC) is now orchestrated through the Abstract Syntax Generator (ASG), ensuring consistency, composability, and type safety.
- Each generator (state, event, cubit, etc.) is a separate module, following the single responsibility principle.
- The main generator coordinates these modules, making it easy to add or modify features.
- BLoC codegen is now triggered via a dedicated tool script (`lib/tools/generate_blocs.dart`), decoupling it from the main build_runner process.
- Utility-based and metadata-driven code generation is emphasized for maintainability.
- Error handling and validation logic are consistently integrated across all generated BLoC code. 