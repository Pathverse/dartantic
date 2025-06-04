# Active Context (Updated)

## Current State - MAJOR MILESTONE ACHIEVED ✅

### FULLY COMPLETED FEATURES
1. **Complete Annotation-Based Validation System**
   - `@DttValidateMethod(function)` - Custom function validation ✅
   - `@DttvMinLength(n)` - Minimum length validation ✅
   - `@DttvMaxLength(n)` - Maximum length validation ✅
   - `@DttvNotNull()` - Null check validation ✅
   - All annotations generate proper validation code ✅

2. **Static Method Processing Pipeline**
   - `_dttpreprocess_{field}` - Data preprocessing ✅
   - `_dttvalidate_{field}` - Custom validation logic ✅
   - `_dttpostprocess_{field}` - Data postprocessing ✅
   - Field existence validation against metadata ✅

3. **Automatic Nested Model Handling**
   - Nested serialization via `dttToMap` ✅
   - Nested deserialization via `dttFromMap` ✅
   - Recursive processing of nested models ✅
   - Support for optional nested models ✅

4. **Generated Methods with dtt Prefix**
   - `dttCreate` - Create with full validation pipeline ✅
   - `dttPreprocess` - Apply preprocessing ✅
   - `dttValidate` - Apply all validations ✅
   - `dttPostprocess` - Apply postprocessing ✅
   - `dttFromMap` - Deserialize from Map with validation ✅
   - `dttToMap` - Serialize to Map with nested support ✅

5. **Model Metadata System**
   - `DttModelMeta` - Field metadata generation ✅
   - `DttFieldMeta` - Individual field information ✅
   - `subModel` detection for nested models ✅
   - Type information with nullability ✅

6. **Modular Architecture (JUST COMPLETED)**
   - Completely refactored from 16KB monolith to modular structure ✅
   - Separated concerns into focused generators ✅
   - Utility classes for common patterns ✅
   - Clean orchestration in main.dart ✅

## Current Work Focus
- CLI command structure and documentation
- BLoC generation workflow improvements
- Enhanced user experience with clear command documentation

## Recent Changes
- Updated CLI command structure with clear subcommands:
  - `bloc` - Generate bloc state management code
  - `model` - Generate model validation logic
- Improved CLI documentation and help messages
- Updated README.md with comprehensive usage examples
- Standardized command execution through `dartantic:dtt` executable

## Next Steps
1. Immediate
   - Verify CLI command documentation is clear and complete
   - Test all CLI commands in various scenarios
   - Ensure help messages are informative
   - Add more examples to documentation

2. Short Term
   - Add more CLI subcommands for advanced features
   - Improve error messages for CLI operations
   - Add progress indicators for long-running operations
   - Enhance CLI configuration options

3. Long Term
   - Add interactive CLI mode
   - Support configuration files
   - Add plugin system for CLI
   - Improve CLI performance

## Active Decisions & Considerations
1. CLI Command Structure
   - Use subcommands for clear organization
   - Provide detailed help messages
   - Follow standard CLI patterns
   - Ensure consistent command naming

2. Documentation
   - Keep README.md up to date
   - Include clear examples
   - Document all commands
   - Provide usage patterns

3. User Experience
   - Clear error messages
   - Consistent command structure
   - Helpful documentation
   - Intuitive command names

## Important Patterns & Preferences
1. CLI Usage
   ```bash
   # Run using package name
   dart run dartantic:dtt <command> [arguments]
   
   # Available commands
   dartantic:dtt bloc    # Generate bloc state management code
   dartantic:dtt model   # Generate model validation logic
   ```

2. Command Structure
   - Use subcommands for organization
   - Provide global options (e.g., --help)
   - Include command-specific arguments
   - Follow standard CLI conventions

## Learnings & Project Insights
- (If applicable) Deep nested validation (using dttFromMap) requires that every nested model (e.g. ContactInfo) has its preprocessing (and validation) methods (e.g. _dttpreprocess_email) defined (and regenerated) so that the generated pipeline (dttFromMap) applies preprocessing (and validation) as intended.

## Active Decisions - PROVEN PATTERNS

### 1. Annotation-Based Validation ✅
- **Direct Code Generation**: Generate validation code from annotation metadata
- **No Validator Instantiation**: Process annotation constants directly
- **Type-Specific Logic**: Different handling per annotation type
- **Error Context**: Rich error messages with field names

### 2. Modular Code Generation ✅
- **Single Responsibility Generators**: One file per method type
- **Utility-Based Patterns**: Shared code generation helpers
- **Clean Orchestration**: Main generator just coordinates
- **Easy Extension**: Adding new methods requires only new generator

### 3. Nested Model Processing ✅
- **Recursive Validation**: Nested models use their own validation pipeline
- **Map-Based Communication**: Models communicate via processed maps
- **Type Safety**: Compile-time nested model detection
- **Optional Handling**: Proper null handling for optional nested models

## Learnings - PROVEN APPROACHES

### 1. Code Generation Success Patterns
- **ASG-First**: Use ASG for all code generation consistency
- **Utility Classes**: Extract common patterns to reduce duplication
- **Metadata-Driven**: Field metadata as single source of truth
- **Direct Generation**: Generate code directly from annotations, not instances

### 2. Validation Architecture
- **Pipeline Processing**: preprocess → validate → postprocess
- **Static Method Detection**: Regex-based field name extraction
- **Annotation Processing**: Direct constant value processing
- **Field Validation**: Always validate against model metadata

### 3. Modular Development
- **Clean Separation**: One generator per method type
- **Shared Utilities**: Common patterns in utility classes
- **Easy Testing**: Test individual generators independently
- **Simple Maintenance**: Changes isolated to specific generators

## Recent Changes - MAJOR REFACTORING COMPLETED

### Modular Architecture Implementation ✅
- **Reduced main.dart**: From 16KB/482 lines to 2.3KB/73 lines (85% reduction)
- **Created Generator Modules**: 7 focused generator files
- **Utility Classes**: 2 utility files with shared patterns
- **Zero Functional Changes**: All 19 tests still pass

### Structure Achieved:
```
lib/core/gen/
├── main.dart (2.3KB) - Clean orchestration
├── generators/ - Focused method generators
│   ├── create_method.dart
│   ├── preprocess_method.dart
│   ├── validate_method.dart
│   ├── postprocess_method.dart
│   ├── frommap_method.dart
│   ├── tomap_method.dart
│   └── metadata.dart
└── utils/ - Shared patterns
    ├── field_utils.dart
    └── code_utils.dart
```

## CRITICAL SUCCESS - CONSTRAINTS RESOLVED

### ✅ WORKING APPROACHES (KEEP THESE)
1. **Direct Annotation Processing**: Process constant values from annotations
2. **Field Metadata as Source of Truth**: Use generated fieldMetaDict for all operations
3. **Static Method Detection**: Regex extraction with metadata validation
4. **Modular Generators**: Single responsibility principle for maintainability

### ❌ FAILED APPROACHES (NEVER RETRY)
1. **Validator Instance Access**: `obj.getField('instance')` returns null
2. **Constructor Arguments**: Direct access to constructor params fails
3. **Field Reflection**: Iterating annotation object fields doesn't work
4. **Hardcoded Types**: Checking specific validator names breaks extensibility

## Current Status: PRODUCTION READY ✅

- **Feature Complete**: All planned features implemented and tested
- **Architecture Excellent**: Clean, modular, maintainable codebase
- **Test Coverage**: Comprehensive test suite with 19 passing tests
- **Performance Ready**: Generated code is efficient and type-safe
- **Developer Experience**: Clean API matching Python Pydantic patterns 

## Current Focus
- BLoC Generation Improvements
  - Case-insensitive annotation detection
  - Proper directory handling
  - Enhanced logging and debugging
  - Robust file scanning

## Recent Changes
1. Improved BLoC Generator
   - Added case-insensitive `@DttBloc` annotation detection
   - Fixed directory handling to use absolute paths
   - Enhanced logging for better debugging
   - Added detailed file scanning statistics
   - Improved error handling and reporting

2. Directory Management
   - Proper handling of working directory
   - Use of absolute paths for file operations
   - Consistent directory state management
   - Clear logging of directory changes

3. Annotation Processing
   - Case-insensitive regex patterns for annotation detection
   - Support for both `@DttBloc` and `@dttBloc` formats
   - Improved validation of annotation format
   - Better error messages for invalid annotations

## Active Decisions
1. Directory Handling
   - Always use absolute paths for file operations
   - Store and restore original directory
   - Log directory changes for debugging
   - Validate directory existence before operations

2. Annotation Detection
   - Use case-insensitive regex for robustness
   - Support multiple annotation formats
   - Validate annotation format before processing
   - Provide clear error messages

3. File Processing
   - Scan both lib and test directories
   - Skip generated files
   - Track scanning statistics
   - Log detailed processing information

## Next Steps
1. Immediate
   - Test directory handling with various project structures
   - Verify annotation detection with different formats
   - Add more test cases for edge cases
   - Improve error messages further

2. Short Term
   - Add support for custom bloc event handling
   - Improve state transition validation
   - Add more validation types
   - Enhance error handling

3. Long Term
   - Support nested bloc states
   - Add middleware support
   - Improve performance
   - Grow community

## Important Patterns
1. Directory Management
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

2. Annotation Detection
   ```dart
   // Case-insensitive annotation detection
   if (RegExp(r'@dttbloc', caseSensitive: false).hasMatch(content)) {
     if (RegExp(r'@dttbloc\s*\(\)|@dttbloc\s*$|@dttbloc\s*[;{]', 
         caseSensitive: false).hasMatch(content)) {
       // Process valid annotation
     }
   }
   ```

3. File Processing
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

## Learnings
1. Directory Management
   - Always use absolute paths for reliability
   - Properly manage directory state
   - Log directory changes for debugging
   - Validate paths before operations

2. Annotation Processing
   - Case-insensitive matching is more robust
   - Multiple annotation formats improve usability
   - Clear validation rules prevent errors
   - Detailed logging helps debugging

3. File Processing
   - Track statistics for better monitoring
   - Skip generated files to prevent loops
   - Log detailed information for debugging
   - Handle errors gracefully

## Current Challenges
1. Directory Handling
   - Ensuring correct working directory
   - Managing directory state
   - Handling path differences
   - Validating directory existence

2. Annotation Detection
   - Supporting multiple formats
   - Validating annotation syntax
   - Providing clear error messages
   - Handling edge cases

3. File Processing
   - Tracking processing statistics
   - Skipping generated files
   - Logging detailed information
   - Handling errors gracefully

## Major Architectural Update (2025-06)

- **ASG Foundation:** All code generation (model, validation, BLoC) now uses the Abstract Syntax Generator (ASG) for unified, type-safe, and extensible output.
- **Modular BlocGen:** BLoC generator is split into focused modules (state, event, cubit, etc.), orchestrated by a main generator for maintainability and extensibility.
- **Tool-Run Workflow:** BLoC codegen is now triggered via `dart run lib/tools/generate_blocs.dart`, decoupling it from build_runner and making the workflow more explicit and modular.
- **Improved Error Handling:** Generated cubits now emit clearer, testable error messages; validation logic is more robust.
- **Test Alignment:** Test expectations updated to match new error message formats and validation logic.
- **Extensibility:** The codebase is now easier to extend with new generator features or validation rules.
- **Next Steps:** Expand ASG features, add granular tests for generator modules, and document the new workflow and architecture. 