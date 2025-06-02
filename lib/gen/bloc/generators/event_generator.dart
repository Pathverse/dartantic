import 'generator_base.dart';
import '../../../../asg/asg.dart';

/// Generates all event-related classes for a bloc
class EventGenerator extends BlocGeneratorBase {
  EventGenerator({
    required super.className,
    required super.fields,
    required super.originalFileName,
  });

  /// Generates all event classes for the bloc
  ASG generate() {
    final asg = ASG();

    // Generate abstract event class
    asg.add(
      ASG.CLASS(
        name: '${blocClassName}Event',
        extendsList: ['Equatable'],
        isAbstract: true,
        constructors: [
          ASG.CONST_CONSTRUCTOR(
            name: '${blocClassName}Event',
            parameters: const [],
            superCall: 'super()',
          ),
        ],
        methods: [
          ASG.GETTER(
            name: 'props',
            returnType: 'List<Object?>',
            isOverride: true,
            body: ASG.fromLines(['return [];']),
          ),
        ],
      ),
    );

    // Generate update events for each field
    for (final field in fields.entries) {
      final eventName = '${blocClassName}Update${_capitalize(field.key)}';
      asg.add(
        ASG.CLASS(
          name: eventName,
          extendsList: ['${blocClassName}Event'],
          fields: [
            ASG.FIELD(name: field.key, type: field.value, isFinal: true),
          ],
          constructors: [
            ASG.CONST_CONSTRUCTOR(
              name: eventName,
              parameters: ['this.${field.key}'],
              superCall: 'super()',
            ),
          ],
          methods: [
            ASG.GETTER(
              name: 'props',
              returnType: 'List<Object?>',
              isOverride: true,
              body: ASG.fromLines(['return [${field.key}];']),
            ),
          ],
        ),
      );
    }

    // Generate standard events
    final standardEvents = <(String, List<String>)>[
      ('Load', const []),
      ('Save', const []),
      ('Reset', const []),
      ('Validate', const []),
    ];

    for (final (name, props) in standardEvents) {
      final eventName = '${blocClassName}$name';
      asg.add(
        ASG.CLASS(
          name: eventName,
          extendsList: ['${blocClassName}Event'],
          constructors: [
            ASG.CONST_CONSTRUCTOR(
              name: eventName,
              parameters: const [],
              superCall: 'super()',
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
        ),
      );
    }

    return asg;
  }

  String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);
}
