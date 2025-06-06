// dart format width=80
// GENERATED BY DARTANTIC

part of 'zbloc_test.dart';

// **************************************************************************
// ModelGenerator
// **************************************************************************

const DttModelMeta _dtt_TestUser_fieldMeta = DttModelMeta(
  fields: {
    'name': DttFieldMeta(
      type: 'String',
      isFinal: true,
      isLate: false,
      subModel: null,
    ),
    'age': DttFieldMeta(
      type: 'int',
      isFinal: true,
      isLate: false,
      subModel: null,
    ),
    'email': DttFieldMeta(
      type: 'String?',
      isFinal: true,
      isLate: false,
      subModel: null,
    ),
  },
);

mixin _$TestUserMixin {
  static Map<String, dynamic> dttCreate({
    required String name,
    required int age,
    String? email,
  }) {
    final values = <String, dynamic>{'name': name, 'age': age, 'email': email};
    final processedValues = dttPreprocess(values);
    dttValidate(processedValues);
    return dttPostprocess(processedValues);
  }

  static Map<String, dynamic> dttPreprocess(Map<String, dynamic> values) {
    // Preprocessing step - modify values before validation
    values['name'] = TestUser._dttpreprocess_name(values['name']);
    return values;
  }

  static void dttValidateField_name(
    dynamic value,
    Map<String, dynamic> values,
  ) {}
  static void dttValidateField_age(dynamic value, Map<String, dynamic> values) {
    if (value != null && !TestUser._dttvalidate_age(value)) {
      throw DttValidationError('age', 'age failed custom validation');
    }
  }

  static void dttValidateField_email(
    dynamic value,
    Map<String, dynamic> values,
  ) {}
  static void dttValidate(Map<String, dynamic> values) {
    if (values['name'] != null) {
      dttValidateField_name(values['name'], values);
    }
    if (values['age'] != null) {
      dttValidateField_age(values['age'], values);
    }
    if (values['email'] != null) {
      dttValidateField_email(values['email'], values);
    }
  }

  static Map<String, dynamic> dttPostprocess(Map<String, dynamic> values) {
    // Postprocessing step - modify values after validation
    // No postprocessing methods found
    return values;
  }

  static Map<String, dynamic> dttFromMap(Map<String, dynamic> map) {
    // Process and validate map data (including nested models)
    final processedMap = <String, dynamic>{
      'name': map['name'],
      'age': map['age'],
      'email': map['email'],
    };
    // Apply preprocessing, validation, and postprocessing to the processed map
    final preprocessed = dttPreprocess(processedMap);
    dttValidate(preprocessed);
    return dttPostprocess(preprocessed);
  }

  static Map<String, dynamic> dttToMap(TestUser obj) {
    // Convert object instance to a map
    return {'name': obj.name, 'age': obj.age, 'email': obj.email};
  }
}
