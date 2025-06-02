#!/usr/bin/env dart

import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:args/command_runner.dart';
import 'package:dartantic/tools/generate_blocs.dart';
import 'package:dartantic/tools/build_runner.dart';

class DartanticCommand extends Command {
  @override
  String get name => 'gen';
  @override
  String get description => 'Parse and generate model validation logic';

  DartanticCommand() {
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
        help: 'Force regeneration of all files',
        defaultsTo: false,
      )
      ..addFlag(
        'bloc',
        abbr: 'b',
        help: 'Generate bloc code in addition to models',
        defaultsTo: false,
      )
      ..addFlag(
        'bloc-only',
        help: 'Generate only bloc code without running model generator',
        defaultsTo: false,
      )
      ..addOption(
        'output',
        abbr: 'o',
        help: 'Output directory for generated files',
        defaultsTo: 'lib/generated',
      );
  }

  @override
  Future<void> run() async {
    final verbose = argResults!['verbose'] as bool;
    final force = argResults!['force'] as bool;
    final bloc = argResults!['bloc'] as bool;
    final blocOnly = argResults!['bloc-only'] as bool;
    final output = argResults!['output'] as String;

    if (verbose) {
      print('Running in verbose mode');
      print('Force regeneration: $force');
      print('Generate bloc: $bloc');
      print('Bloc only mode: $blocOnly');
      print('Output directory: $output');
    }

    await _runGenerate(verbose, force, bloc, blocOnly, output);
  }

  void printUsage() {
    print('Usage: dart run dartantic gen [options]');
    print('\nOptions:');
    print(argParser.usage);
  }
}

class TestCommand extends Command {
  @override
  String get name => 'test';
  @override
  String get description => 'Run tests';

  TestCommand() {
    argParser
      ..addFlag(
        'coverage',
        abbr: 'c',
        help: 'Generate coverage report',
        defaultsTo: false,
      )
      ..addOption('name', abbr: 'n', help: 'Run tests matching name pattern');
  }

  @override
  Future<void> run() async {
    final coverage = argResults!['coverage'] as bool;
    final name = argResults!['name'] as String?;
    final verbose = (parent as DartanticCommand).argResults!['verbose'] as bool;

    if (verbose) {
      print('Generate coverage: $coverage');
      if (name != null) print('Test name pattern: $name');
    }

    await _runTest(verbose, coverage, name);
  }
}

Future<void> _runGenerate(
  bool verbose,
  bool force,
  bool bloc,
  bool blocOnly,
  String output,
) async {
  if (verbose) print('Generating code...');

  // Store the original directory (user's package) BEFORE any directory changes
  final userProjectDir = Directory.current;
  final scriptPath = Platform.script.path;
  final packageRoot = path.dirname(path.dirname(scriptPath));

  try {
    // Create a function that runs build_runner in the user's package
    Future<void> runBuildRunnerInUserPackage(List<String> args) async {
      // Always ensure we're in the user's package directory
      Directory.current = userProjectDir;

      // Construct the full build_runner command
      final buildRunnerArgs = ['run', 'build_runner', 'build'];
      if (args.contains('--delete-conflicting-outputs')) {
        buildRunnerArgs.add('--delete-conflicting-outputs');
      }

      print('🏗️  Running build_runner in directory: ${userProjectDir.path}');
      print('🏗️  Command: dart ${buildRunnerArgs.join(" ")}');

      final result = await Process.run(
        'dart',
        buildRunnerArgs,
        workingDirectory: userProjectDir.path,
      );

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
    }

    // Run build_runner only once at the start
    if (!blocOnly) {
      await runBuildRunnerInUserPackage(['--delete-conflicting-outputs']);
    }

    if (bloc || blocOnly) {
      // Change to the package root for bloc generation
      Directory.current = Directory(packageRoot);
      print('📦 Changed to package root: ${packageRoot}');

      try {
        // Generate blocs without running build_runner again
        await generateBlocs(
          skipModelGen: true, // Skip model gen since we already ran it
          runBuildRunnerInPackage: null, // Don't run build_runner again
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

Future<void> _runTest(bool verbose, bool coverage, String? name) async {
  if (verbose) print('Running tests...');

  final testArgs = ['test'];
  if (coverage) {
    testArgs.add('--coverage');
  }
  if (name != null) {
    testArgs.add('--name');
    testArgs.add(name);
  }

  final result = await Process.run('flutter', testArgs);
  print(result.stdout);
  if (result.stderr.isNotEmpty) {
    print(result.stderr);
  }
}

void main(List<String> args) async {
  final runner =
      CommandRunner(
          'dartantic',
          'A powerful model validation and processing system using decorators.',
        )
        ..addCommand(DartanticCommand())
        ..addCommand(TestCommand());

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
