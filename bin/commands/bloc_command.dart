import 'dart:io';
import 'package:args/command_runner.dart';
import '../utils/generator.dart';

class MakeBlocCommand extends Command {
  @override
  String get name => 'bloc';
  @override
  String get description => 'Generate bloc state management code';

  MakeBlocCommand() {
    argParser
      ..addFlag(
        'verbose',
        abbr: 'v',
        help: 'Enable verbose output',
        defaultsTo: false,
      )
      ..addFlag(
        'force',
        abbr: 'f',
        help: 'Force regeneration of all bloc files',
        defaultsTo: false,
      );
  }

  @override
  Future<void> run() async {
    final verbose = argResults!['verbose'] as bool;
    final force = argResults!['force'] as bool;
    final targetDir = argResults!.rest.isNotEmpty ? argResults!.rest.first : '';

    if (verbose) {
      print('Running in verbose mode');
      print('Force regeneration: $force');
      if (targetDir.isNotEmpty) {
        print('Target directory: $targetDir');
      }
    }

    await runBlocGenerate(verbose, force, targetDir);
  }
}
