import 'dart:io';

/// Runs the build_runner with the given arguments
Future<void> runBuildRunner(List<String> args) async {
  print('🏗️  Running build_runner...');

  // Build the command
  final command = ['dart', 'run', 'build_runner', 'build', ...args];

  // Run the command
  final result = await Process.run(
    command[0],
    command.sublist(1),
    runInShell: true,
  );

  // Print output
  if (result.stdout.isNotEmpty) {
    print(result.stdout);
  }
  if (result.stderr.isNotEmpty) {
    print(result.stderr);
  }

  // Check exit code
  if (result.exitCode != 0) {
    throw Exception('Build runner failed with exit code ${result.exitCode}');
  }

  print('✅ Build runner completed successfully');
}
