#!/usr/bin/env dart

import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:args/command_runner.dart';
import 'package:dartantic/gen/bloc/main.dart' show BlocGenerator;

class MakeCommand extends Command {
  @override
  String get name => 'make';
  @override
  String get description => 'Generate code using dartantic';

  MakeCommand() {
    addSubcommand(MakeModelCommand());
    addSubcommand(MakeBlocCommand());
  }
}

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
    }

    await _runModelGenerate(verbose, force, bloc);
  }
}

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

    if (verbose) {
      print('Running in verbose mode');
      print('Force regeneration: $force');
    }

    await _runBlocGenerate(verbose, force);
  }
}

/// Main function to generate blocs in the current package
Future<void> _generateBlocs({
  bool skipCleanup = false,
  String? workingDirectory,
}) async {
  // Store original directory
  final originalDir = Directory.current;
  final projectDir =
      workingDirectory != null ? Directory(workingDirectory) : originalDir;

  try {
    // Change to project directory
    Directory.current = projectDir;
    print('📂 Working in directory: ${projectDir.path}');

    // Check for .dartantic.g.dart files
    var foundMetadataFiles = false;
    await for (final entity in Directory(
      path.join(projectDir.path, 'lib'),
    ).list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dartantic.g.dart')) {
        foundMetadataFiles = true;
        break;
      }
    }

    if (!foundMetadataFiles) {
      print(
        '❌ No .dartantic.g.dart files found. Please run "dart run dartantic make model" first.',
      );
      exit(1);
    }

    // Generate blocs (cleanup is handled inside BlocGenerator)
    print('🔄 Generating bloc files...');
    await BlocGenerator.generate(
      skipCleanup: skipCleanup,
      workingDirectory: workingDirectory,
    );
    print('✅ Bloc generation completed');
  } finally {
    // Always restore original directory
    Directory.current = originalDir;
  }
}

Future<void> _runModelGenerate(bool verbose, bool force, bool bloc) async {
  if (verbose) print('Generating model code...');

  // Store the original directory (user's package)
  final userProjectDir = Directory.current;
  final scriptPath = Platform.script.path;
  final packageRoot = path.dirname(path.dirname(scriptPath));

  try {
    // Run build_runner for model generation
    print('🏗️  Running build_runner in directory: ${userProjectDir.path}');
    print(
      '🏗️  Command: dart run build_runner build --delete-conflicting-outputs',
    );

    final result = await Process.run('dart', [
      'run',
      'build_runner',
      'build',
      '--delete-conflicting-outputs',
    ], workingDirectory: userProjectDir.path);

    if (result.stdout.isNotEmpty) {
      print(result.stdout);
    }

    if (result.exitCode != 0) {
      final errorMessage =
          result.stderr.isNotEmpty
              ? result.stderr
              : 'Build runner failed with no error output';
      print('❌ Build runner error output:');
      print(errorMessage);
      throw Exception(
        'Build runner failed with exit code ${result.exitCode}\n$errorMessage',
      );
    }

    if (result.stderr.isNotEmpty) {
      print('⚠️  Build runner warnings:');
      print(result.stderr);
    }

    // Generate blocs if requested
    if (bloc) {
      // Change to the package root for bloc generation
      Directory.current = Directory(packageRoot);
      print('📦 Changed to package root: ${packageRoot}');

      try {
        // Generate blocs
        await _generateBlocs(
          skipCleanup: true, // Skip cleanup since it's handled by generateBlocs
          workingDirectory:
              userProjectDir.path, // Pass the user's project directory
        );
      } catch (e, stackTrace) {
        print('❌ Error during bloc generation:');
        print(e);
        print('Stack trace:');
        print(stackTrace);
        rethrow;
      }
    }
  } finally {
    // Always restore the original directory
    Directory.current = userProjectDir;
  }
}

Future<void> _runBlocGenerate(bool verbose, bool force) async {
  if (verbose) print('Generating bloc code...');

  // Store the original directory (user's package)
  final userProjectDir = Directory.current;
  final scriptPath = Platform.script.path;
  final packageRoot = path.dirname(path.dirname(scriptPath));

  try {
    // Change to the package root for bloc generation
    Directory.current = Directory(packageRoot);
    print('📦 Changed to package root: ${packageRoot}');

    try {
      // Generate blocs
      await _generateBlocs(
        skipCleanup: !force, // Skip cleanup if not forcing regeneration
        workingDirectory:
            userProjectDir.path, // Pass the user's project directory
      );
    } catch (e, stackTrace) {
      print('❌ Error during bloc generation:');
      print(e);
      print('Stack trace:');
      print(stackTrace);
      rethrow;
    }
  } finally {
    // Always restore the original directory
    Directory.current = userProjectDir;
  }
}

void main(List<String> args) async {
  final runner = CommandRunner(
    'dartantic',
    'A powerful model validation and processing system using decorators.',
  )..addCommand(MakeCommand());

  try {
    await runner.run(args);
  } on UsageException catch (e) {
    print(e);
    exit(64); // Exit code 64 indicates command line usage error
  } catch (e) {
    print('Error: $e');
    exit(1);
  }
}
