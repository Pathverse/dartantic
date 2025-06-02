import 'generator_base.dart';
import '../../../../asg/asg.dart';

/// Generates all state-related classes for a bloc
class StateGenerator extends BlocGeneratorBase {
  StateGenerator({
    required super.className,
    required super.fields,
    required super.originalFileName,
  });

  /// Generates all state classes for the bloc
  ASG generate() {
    final asg = ASG();

    // Generate abstract state class with factory methods
    asg.add(
      ASG.CLASS(
        name: '${blocClassName}State',
        extendsList: ['Equatable'],
        isAbstract: true,
        constructors: [
          ASG.CONST_CONSTRUCTOR(
            name: '${blocClassName}State',
            parameters: const [],
            superCall: 'super()',
          ),
        ],
        methods: [
          // Props getter
          ASG.GETTER(
            name: 'props',
            returnType: 'List<Object?>',
            isOverride: true,
            body: ASG.fromLines(['return [];']),
          ),
          // Factory methods
          ASG.METHOD(
            name: 'initial',
            returnType: '${blocClassName}State',
            isStatic: true,
            body: ASG.fromLines(['return const ${blocClassName}Initial();']),
          ),
          ASG.METHOD(
            name: 'loading',
            returnType: '${blocClassName}State',
            isStatic: true,
            body: ASG.fromLines(['return const ${blocClassName}Loading();']),
          ),
          ASG.METHOD(
            name: 'error',
            returnType: '${blocClassName}State',
            isStatic: true,
            parameters: ['String message'],
            body: ASG.fromLines(['return ${blocClassName}Error(message);']),
          ),
          ASG.METHOD(
            name: 'success',
            returnType: '${blocClassName}State',
            isStatic: true,
            parameters: ['${blocClassName}StateData data'],
            body: ASG.fromLines(['return data;']),
          ),
        ],
      ),
    );

    // Generate state data class
    asg.add(
      ASG.CLASS(
        name: '${blocClassName}StateData',
        extendsList: ['${blocClassName}State'],
        fields:
            fields.entries.map((field) {
              final type = field.value;
              return ASG.FIELD(name: field.key, type: type, isFinal: true);
            }).toList(),
        constructors: [
          createStateDataConstructor(
            name: '${blocClassName}StateData',
            fields: fields,
          ),
        ],
        methods: [
          createFromMapConstructor(
            name: '${blocClassName}StateData',
            fields: fields,
          ),
          createToMapMethod(),
          createCopyWithMethod(
            name: '${blocClassName}StateData',
            fields: fields,
          ),
          ASG.GETTER(
            name: 'props',
            returnType: 'List<Object?>',
            isOverride: true,
            body: ASG.fromLines([
              'return [',
              ...fields.keys.map((field) => '    $field,'),
              '  ];',
            ]),
          ),
        ],
      ),
    );

    // Generate loading state
    asg.add(
      createEquatableClass(
        name: '${blocClassName}Loading',
        props: const [],
        extendsList: ['${blocClassName}State'],
      ),
    );

    // Generate error state
    asg.add(
      ASG.CLASS(
        name: '${blocClassName}Error',
        extendsList: ['${blocClassName}State'],
        fields: [ASG.FIELD(name: 'message', type: 'String', isFinal: true)],
        constructors: [
          ASG.CONST_CONSTRUCTOR(
            name: '${blocClassName}Error',
            parameters: ['this.message'],
          ),
        ],
        methods: [
          ASG.GETTER(
            name: 'props',
            returnType: 'List<Object?>',
            isOverride: true,
            body: ASG.fromLines(['return [message];']),
          ),
        ],
      ),
    );

    // Generate initial state
    asg.add(
      createEquatableClass(
        name: '${blocClassName}Initial',
        props: const [],
        extendsList: ['${blocClassName}State'],
      ),
    );

    return asg;
  }
}
