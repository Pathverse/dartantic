import '../../asg/asg.dart';
import 'package:path/path.dart' as path;

/// Base class for all bloc generators that provides common utilities
abstract class BlocGeneratorBase {
  final String className;
  final Map<String, String> fields;
  final String originalFileName;
  final String blocClassName;

  BlocGeneratorBase({
    required this.className,
    required this.fields,
    required this.originalFileName,
  }) : blocClassName = 'DttBloc$className';

  /// Creates a new ASG instance with the standard bloc file header
  ASG createBlocFile() {
    final asg = ASG();
    asg.addLine('// GENERATED CODE - DO NOT MODIFY BY HAND');
    asg.addLine('// ignore_for_file: type=lint');
    asg.addLine('');
    asg.addLine('part of \'${path.basename(originalFileName)}\';');
    asg.addLine('');
    return asg;
  }

  /// Generates a standard Equatable class with props
  ASG createEquatableClass({
    required String name,
    required List<String> props,
    bool isAbstract = false,
    List<String>? extendsList,
  }) {
    return ASG.CLASS(
      name: name,
      extendsList: extendsList ?? ['Equatable'],
      isAbstract: isAbstract,
      constructors: [
        ASG.CONST_CONSTRUCTOR(
          name: name,
          parameters: const [],
          superCall: extendsList != null ? 'super()' : null,
        ),
      ],
      methods: [
        ASG.GETTER(
          name: 'props',
          returnType: 'List<Object?>',
          isOverride: true,
          body: ASG.fromLines([
            'return [',
            ...props.map((prop) => '    $prop,'),
            '  ];',
          ]),
        ),
      ],
    );
  }

  /// Generates a standard factory constructor for state classes
  ASG createStateFactory({
    required String stateName,
    required String returnType,
    List<String>? parameters,
  }) {
    final paramsStr = parameters?.join(', ') ?? '';
    return ASG.METHOD(
      name: stateName,
      returnType: returnType,
      parameters: parameters == null ? null : List<String>.from(parameters),
      isStatic: true,
      body: ASG.fromLines(['return ${returnType}($paramsStr);']),
    );
  }

  /// Creates a constructor for a state class
  ASG createStateConstructor({
    required String name,
    List<String> parameters = const [],
    List<String> initializers = const [],
    String? superCall,
  }) {
    return ASG.NO_BODY_CONSTRUCTOR(
      name: name,
      parameters: parameters,
      initializers: initializers,
      superCall: superCall,
    );
  }

  /// Creates a constructor for an event class
  ASG createEventConstructor({
    required String name,
    List<String> parameters = const [],
    List<String> initializers = const [],
    String? superCall,
  }) {
    return ASG.CONST_CONSTRUCTOR(
      name: name,
      parameters: parameters,
      initializers: initializers,
      superCall: superCall,
    );
  }

  /// Generates a standard constructor for state data classes
  ASG createStateDataConstructor({
    required String name,
    required Map<String, String> fields,
    String? superCall,
  }) {
    final parameters = fields.entries.map((e) => 'this.${e.key}').toList();
    final initializers = superCall != null ? <String>[superCall] : <String>[];

    return ASG.NO_BODY_CONSTRUCTOR(
      name: name,
      parameters: parameters.cast<String>(),
      initializers: initializers.cast<String>(),
    );
  }

  /// Generates a copyWith method for state data classes
  ASG createCopyWithMethod({
    required String name,
    required Map<String, String> fields,
  }) {
    final parameters =
        fields.entries.map((e) {
          final type = e.value;
          final isNullable = type.endsWith('?');
          final baseType = isNullable ? type : '$type?';
          return '$baseType ${e.key}';
        }).toList();

    final copyWithBody = ASG.fromLines([
      'return $name(',
      ...fields.entries.map((e) => '  ${e.key} ?? this.${e.key},'),
      ');',
    ]);

    return ASG.METHOD(
      name: 'copyWith',
      returnType: name,
      parameters: parameters,
      body: copyWithBody,
    );
  }

  /// Generates a fromMap constructor for state data classes
  ASG createFromMapConstructor({
    required String name,
    required Map<String, String> fields,
    String? superCall,
  }) {
    final initializers = <String>[
      ...fields.entries.map((e) {
        final fieldName = e.key;
        final fieldType = e.value;
        return '${fieldName} = map[\'${fieldName}\'] as $fieldType';
      }),
      if (superCall != null) superCall,
    ];

    return ASG.CONSTRUCTOR(
      name: '$name.fromMap',
      parameters: ['Map<String, dynamic> map'],
      initializers: initializers,
    );
  }

  /// Generates a standard toMap method for state data classes
  ASG createToMapMethod() {
    final assignments = <String>[
      ...fields.entries.map((field) => '\'${field.key}\': ${field.key},'),
    ];

    return ASG.METHOD(
      name: 'toMap',
      returnType: 'Map<String, dynamic>',
      body: ASG.fromLines([
        'return {',
        ...assignments.map((a) => '    $a'),
        '  };',
      ]),
    );
  }
}
