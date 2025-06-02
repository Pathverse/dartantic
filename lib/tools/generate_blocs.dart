#!/usr/bin/env dart

import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:dartantic/gen/bloc/main.dart';
import 'package:dartantic/tools/build_runner.dart';

/// Main function to generate blocs in the current package
Future<void> generateBlocs({
  bool skipModelGen = false,
  Future<void> Function(List<String> args)? runBuildRunnerInPackage,
  bool skipCleanup = false,
  String? workingDirectory,
}) async {
  // Run model generator only if not skipped
  if (!skipModelGen) {
    print('🔄 Running model generator first...');
    if (runBuildRunnerInPackage != null) {
      await runBuildRunnerInPackage(['--delete-conflicting-outputs']);
    } else {
      await runBuildRunner(['--delete-conflicting-outputs']);
    }
  } else {
    print('⏩ Skipping model generator as requested...');
  }

  // Generate blocs (cleanup is handled inside BlocGenerator)
  print('🔄 Generating bloc files...');
  await BlocGenerator.generate(
    skipCleanup: skipCleanup,
    workingDirectory: workingDirectory,
  );
  print('✅ Bloc generation completed');
}

/// Entry point when run as a script
void main(List<String> args) async {
  final skipModelGen = args.contains('--skip-model-gen');
  final skipCleanup = args.contains('--skip-cleanup');

  try {
    await generateBlocs(skipModelGen: skipModelGen, skipCleanup: skipCleanup);
  } catch (e) {
    print('❌ Error: $e');
    exit(1);
  }
}
