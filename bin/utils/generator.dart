import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:dartantic/gen/bloc/main.dart' show BlocGenerator;

/// Generate blocs for models with @dttBloc annotation
Future<void> generateBlocs({
  bool skipCleanup = false,
  bool verbose = false,
  String targetDir = '',
}) async {
  final projectDir = Directory.current;
  if (verbose) {
    print('📂 Working in directory: ${projectDir.path}');
  }

  // Find all Dart files that might contain @dttBloc
  final dartFiles = <File>[];

  // If target directory is specified, only scan that directory
  if (targetDir.isNotEmpty) {
    final dir = Directory(targetDir);
    if (!await dir.exists()) {
      print('❌ Target directory not found: $targetDir');
      return;
    }

    await for (final entity in dir.list(recursive: true)) {
      if (entity is File &&
          entity.path.endsWith('.dart') &&
          !entity.path.endsWith('.g.dart')) {
        final content = await entity.readAsString();
        if (content.contains('@dttBloc')) {
          dartFiles.add(entity);
        }
      }
    }
  } else {
    // Scan both lib and test directories
    for (final dirName in ['lib', 'test']) {
      final dir = Directory(dirName);
      if (!await dir.exists()) continue;

      await for (final entity in dir.list(recursive: true)) {
        if (entity is File &&
            entity.path.endsWith('.dart') &&
            !entity.path.endsWith('.g.dart')) {
          final content = await entity.readAsString();
          if (content.contains('@dttBloc')) {
            dartFiles.add(entity);
          }
        }
      }
    }
  }

  if (dartFiles.isEmpty) {
    if (targetDir.isNotEmpty) {
      print('ℹ️  No files with @dttBloc annotation found in $targetDir');
    } else {
      print('ℹ️  No files with @dttBloc annotation found in lib/ or test/');
    }
    return;
  }

  if (verbose) {
    print('📝 Found ${dartFiles.length} files with @dttBloc annotation:');
    for (final file in dartFiles) {
      print('  - ${path.relative(file.path)}');
    }
  }

  // Generate blocs
  print('🔄 Generating bloc files...');
  await BlocGenerator.generate(skipCleanup: skipCleanup, dartFiles: dartFiles);
  print('✅ Bloc generation completed');
}

/// Run model generation with build_runner
Future<void> runModelGenerate(
  bool verbose,
  bool force,
  bool bloc,
  String targetDir,
) async {
  if (verbose) print('Generating model code...');

  // Run build_runner for model generation
  print('🏗️  Running build_runner...');
  final result = await Process.run('dart', [
    'run',
    'build_runner',
    'build',
    '--delete-conflicting-outputs',
  ]);

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
    await generateBlocs(
      skipCleanup: true,
      verbose: verbose,
      targetDir: targetDir,
    );
  }
}

/// Run bloc generation
Future<void> runBlocGenerate(bool verbose, bool force, String targetDir) async {
  if (verbose) print('Generating bloc code...');
  await generateBlocs(
    skipCleanup: !force,
    verbose: verbose,
    targetDir: targetDir,
  );
}
