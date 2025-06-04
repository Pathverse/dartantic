#!/usr/bin/env dart

import 'dart:io';

import 'package:args/command_runner.dart';
import 'commands/bloc_command.dart';
import 'commands/model_command.dart';

void main(List<String> arguments) async {
  final runner =
      CommandRunner(
          'dartantic',
          'A code generation tool for Dart models and BLoCs',
        )
        ..addCommand(MakeBlocCommand())
        ..addCommand(MakeModelCommand());

  try {
    await runner.run(arguments);
  } on UsageException catch (e) {
    print(e);
    exit(64); // Exit code 64 indicates a usage error
  } catch (e) {
    print('❌ Error: $e');
    exit(1);
  }
}
