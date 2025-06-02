import 'generator_base.dart';
import '../../../../asg/asg.dart';

/// Generates the cubit class for a bloc
class CubitGenerator extends BlocGeneratorBase {
  CubitGenerator({
    required super.className,
    required super.fields,
    required super.originalFileName,
  });

  /// Generates the cubit class with all its methods
  ASG generate() {
    final asg = ASG();

    // Generate cubit class
    asg.add(
      ASG.CLASS(
        name: '${blocClassName}Cubit',
        extendsList: ['Cubit<${blocClassName}State>'],
        constructors: [
          ASG.CONSTRUCTOR(
            name: '${blocClassName}Cubit',
            parameters: const [],
            superCall: 'super(${blocClassName}State.initial())',
          ),
        ],
        methods: [
          // Update methods for each field
          ...fields.entries.map((field) {
            final fieldName = field.key;
            final fieldType = field.value;
            final updateName = 'update${_capitalize(fieldName)}';

            return ASG.METHOD(
              name: updateName,
              returnType: 'void',
              parameters: ['$fieldType $fieldName'],
              body: ASG.fromLines([
                'if (isClosed) return;',
                'if (state is ${blocClassName}StateData) {',
                '  final currentState = state as ${blocClassName}StateData;',
                '  try {',
                '    // Create a map with current values and new value',
                '    final values = <String, dynamic>{',
                ...fields.keys.map(
                  (k) =>
                      '      \'$k\': ${k == field.key ? fieldName : "currentState.$k"},',
                ),
                '    };',
                '    // Apply preprocessing and validation using the mixin methods',
                '    final processedValues = _\$${className}Mixin.dttPreprocess(values);',
                '    _\$${className}Mixin.dttValidate(processedValues);',
                '    // Emit new state with processed values',
                '    emit(currentState.copyWith(',
                ...fields.keys.map((k) => '      processedValues[\'$k\'],'),
                '    ));',
                '  } on DttValidationError catch (error) {',
                '    emit(${blocClassName}State.error(\'Invalid \' + error.field + \': \' + error.message));',
                '  } catch (error) {',
                '    emit(${blocClassName}State.error(error.toString()));',
                '  }',
                '}',
              ]),
            );
          }),

          // Load data method
          ASG.METHOD(
            name: 'loadData',
            returnType: 'Future<void>',
            parameters: ['Map<String, dynamic> data'],
            isAsync: true,
            body: ASG.fromLines([
              'if (isClosed) return;',
              'emit(${blocClassName}State.loading());',
              'try {',
              '  // Process and validate the data using the mixin methods',
              '  final processedData = _\$${className}Mixin.dttFromMap(data);',
              '  final stateData = ${blocClassName}StateData.fromMap(processedData);',
              '  if (!isClosed) {',
              '    emit(stateData);',
              '  }',
              '} on DttValidationError catch (error) {',
              '  if (!isClosed) {',
              '    emit(${blocClassName}State.error(\'Invalid \' + error.field + \': \' + error.message));',
              '  }',
              '} catch (error) {',
              '  if (!isClosed) {',
              '    emit(${blocClassName}State.error(error.toString()));',
              '  }',
              '}',
            ]),
          ),

          // Validate method
          ASG.METHOD(
            name: 'validate',
            returnType: 'bool',
            body: ASG.fromLines([
              'if (state is! ${blocClassName}StateData) return false;',
              'final currentState = state as ${blocClassName}StateData;',
              'try {',
              '  final values = currentState.toMap();',
              '  _\$${className}Mixin.dttValidate(values);',
              '  return true;',
              '} catch (error) {',
              '  return false;',
              '}',
            ]),
          ),

          // Save data method
          ASG.METHOD(
            name: 'saveData',
            returnType: 'Future<void>',
            isAsync: true,
            body: ASG.fromLines([
              'if (isClosed) return;',
              'if (state is! ${blocClassName}StateData) {',
              '  emit(${blocClassName}State.error(\'No data to save\'));',
              '  return;',
              '}',
              'final currentState = state as ${blocClassName}StateData;',
              'emit(${blocClassName}State.loading());',
              'try {',
              '  // Validate before saving',
              '  if (!validate()) {',
              '    if (!isClosed) {',
              '      emit(${blocClassName}State.error(\'Invalid data\'));',
              '    }',
              '    return;',
              '  }',
              '  // TODO: Implement actual save logic',
              '  await Future.delayed(Duration.zero); // Simulate async operation',
              '  if (!isClosed) {',
              '    emit(currentState);',
              '  }',
              '} catch (error) {',
              '  if (!isClosed) {',
              '    emit(${blocClassName}State.error(error.toString()));',
              '  }',
              '}',
            ]),
          ),

          // Reset method
          ASG.METHOD(
            name: 'reset',
            returnType: 'void',
            body: ASG.fromLines([
              'if (isClosed) return;',
              'emit(${blocClassName}State.initial());',
            ]),
          ),
        ],
      ),
    );

    return asg;
  }

  String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);
}
