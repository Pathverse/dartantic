import 'package:analyzer/dart/element/element.dart';
import 'package:dartantic/asg/asg.dart';
import '../utils/field_utils.dart';
import '../utils/code_utils.dart';

class ValidateMethodGenerator {
  static List<ASG> generate(
    ClassElement element,
    Map<String, dynamic> fieldMetaDict,
  ) {
    final methods = <ASG>[];
    final fieldValidations = <String, List<String>>{};

    // Initialize validation map for all fields
    for (final fieldName in fieldMetaDict.keys) {
      fieldValidations[fieldName] = [];
    }

    // Process field annotations using fieldMetaDict - generate validation code for each field
    _generateAnnotationValidations(element, fieldMetaDict, fieldValidations);

    // Process static validation methods
    _generateStaticValidations(element, fieldMetaDict, fieldValidations);

    // Generate individual field validation methods for ALL fields
    for (final fieldName in fieldMetaDict.keys) {
      final validationLines = fieldValidations[fieldName] ?? [];

      // Always generate the method, even if empty
      methods.add(
        CodeUtils.createMethod(
          name: 'dttValidateField_$fieldName',
          returnType: 'void',
          parameters: ['dynamic value', 'Map<String, dynamic> values'],
          bodyLines:
              validationLines.map((line) {
                // Replace values['fieldName'] with value in the validation lines
                // Also fix any incorrect references to values['value']
                return line
                    .replaceAll("values['$fieldName']", 'value')
                    .replaceAll("values['value']", 'value');
              }).toList(),
        ),
      );
    }

    // Generate main dttValidate method that uses the individual field validations
    final mainValidationLines = <String>[];
    for (final fieldName in fieldMetaDict.keys) {
      mainValidationLines.add(
        'if (values[\'$fieldName\'] != null){ dttValidateField_$fieldName(values[\'$fieldName\'], values); }',
      );
    }

    methods.add(
      CodeUtils.createMethod(
        name: 'dttValidate',
        returnType: 'void',
        parameters: ['Map<String, dynamic> values'],
        bodyLines: mainValidationLines,
      ),
    );

    return methods;
  }

  static void _generateAnnotationValidations(
    ClassElement element,
    Map<String, dynamic> fieldMetaDict,
    Map<String, List<String>> fieldValidations,
  ) {
    for (final fieldName in fieldMetaDict.keys) {
      // Find the actual field element to get annotations
      final field = element.fields.firstWhere(
        (f) => f.name == fieldName && !f.isStatic,
        orElse: () => throw StateError('Field $fieldName not found'),
      );

      // Check each annotation on the field
      for (final annotation in field.metadata) {
        final obj = annotation.computeConstantValue();
        if (obj == null) continue;

        final typeStr = obj.type?.getDisplayString();
        if (typeStr == null) continue;

        // Generate validation code based on annotation type
        try {
          if (typeStr == 'DttvNotNull') {
            fieldValidations[fieldName]!.addAll(
              CodeUtils.generateNullCheck(fieldName).map((line) {
                return line.replaceAll("values['$fieldName']", 'value');
              }),
            );
          } else if (typeStr == 'DttvMinLength') {
            final minLength = obj.getField('minLength')?.toIntValue() ?? 0;
            fieldValidations[fieldName]!.addAll(
              CodeUtils.generateConditionalValidation(
                fieldName,
                'value.length < $minLength',
                '$fieldName must be at least $minLength characters',
              ),
            );
          } else if (typeStr == 'DttvMaxLength') {
            final maxLength = obj.getField('maxLength')?.toIntValue() ?? 0;
            fieldValidations[fieldName]!.addAll(
              CodeUtils.generateConditionalValidation(
                fieldName,
                'value.length > $maxLength',
                '$fieldName must be at most $maxLength characters',
              ),
            );
          } else if (typeStr == 'DttValidateMethod') {
            // Get the function parameter from the annotation
            final funcField = obj.getField('func');
            if (funcField != null) {
              final funcName = funcField.toFunctionValue()?.displayName;
              if (funcName != null) {
                fieldValidations[fieldName]!.addAll(
                  CodeUtils.generateConditionalValidation(
                    fieldName,
                    '!$funcName(value)',
                    '$fieldName failed custom validation',
                  ),
                );
              }
            }
          }
        } catch (e) {
          fieldValidations[fieldName]!.add(
            '// Error generating validation for $typeStr on $fieldName: $e',
          );
        }
      }
    }
  }

  static void _generateStaticValidations(
    ClassElement element,
    Map<String, dynamic> fieldMetaDict,
    Map<String, List<String>> fieldValidations,
  ) {
    final validateMethods = FieldUtils.getStaticMethodsByType(
      element,
      'validate',
    );

    for (final method in validateMethods) {
      final fieldName = FieldUtils.extractFieldName(method.name, 'validate');
      if (fieldName != null &&
          FieldUtils.fieldExistsInMeta(fieldName, fieldMetaDict)) {
        final hasValuesParam = method.parameters.length > 1;
        final validationCall = CodeUtils.generateStaticMethodCall(
          element.name,
          method.name,
          'value',
          hasValuesParam,
        );

        fieldValidations[fieldName]!.addAll(
          CodeUtils.generateConditionalValidation(
            fieldName,
            '!$validationCall',
            '$fieldName failed custom validation',
          ),
        );
      } else if (fieldName != null) {
        fieldValidations[fieldName]!.add(
          CodeUtils.generateFieldWarning(fieldName),
        );
      }
    }
  }
}
