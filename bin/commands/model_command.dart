import 'dart:io';
import 'package:args/command_runner.dart';
import '../utils/generator.dart';

class MakeModelCommand extends Command {
  @override
  String get name => 'model';
  @override
  String get description => 'Generate model validation logic';

  MakeModelCommand() {
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
        help: 'Force regeneration of all model files',
        defaultsTo: false,
      )
      ..addFlag(
        'bloc',
        abbr: 'b',
        help: 'Generate bloc code in addition to models',
        defaultsTo: false,
      );
  }

  @override
  Future<void> run() async {
    final verbose = argResults!['verbose'] as bool;
    final force = argResults!['force'] as bool;
    final bloc = argResults!['bloc'] as bool;
    final targetDir = argResults!.rest.isNotEmpty ? argResults!.rest.first : '';

    if (force && bloc) {
      throw UsageException(
        'Cannot use --force and --bloc together',
        'Use --force for model regeneration or --bloc for bloc generation, but not both',
      );
    }

    if (verbose) {
      print('Running in verbose mode');
      print('Force regeneration: $force');
      print('Generate bloc: $bloc');
      if (targetDir.isNotEmpty) {
        print('Target directory: $targetDir');
      }
    }

    await runModelGenerate(verbose, force, bloc, targetDir);
  }
}
