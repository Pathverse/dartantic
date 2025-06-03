import 'dart:io';
import 'package:path/path.dart' as path;
import 'generators/state_generator.dart';
import 'generators/event_generator.dart';
import 'generators/cubit_generator.dart';
import '../../asg/asg.dart';

/// Main bloc generator class that orchestrates all generators
class BlocGenerator {
  /// Generates bloc files for all annotated classes
  static Future<void> generate({
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

      // Clean up existing bloc files first if not skipped
      if (!skipCleanup) {
        print('🧹 Cleaning up existing bloc files...');
        await _cleanupExistingBlocFiles(projectDir.path);
      }

      // Then generate new blocs
      print('🔄 Scanning for @dttBloc annotated classes...');
      var scannedFiles = 0;
      var foundFiles = 0;
      var generatedFiles = 0;

      // Process lib directory
      final libDir = Directory(path.join(projectDir.path, 'lib'));
      if (await libDir.exists()) {
        print('📂 Scanning lib directory: ${libDir.path}');
        await for (final entity in libDir.list(recursive: true)) {
          if (entity is File && entity.path.endsWith('.dart')) {
            scannedFiles++;
            final relativePath = path.relative(
              entity.path,
              from: projectDir.path,
            );
            print('🔍 Scanning file: $relativePath');
            final content = await entity.readAsString();
            if (RegExp(r'@dttbloc', caseSensitive: false).hasMatch(content)) {
              print('  Found @DttBloc annotation in file');
              if (RegExp(
                r'@dttbloc\s*\(\)|@dttbloc\s*$|@dttbloc\s*[;{]',
                caseSensitive: false,
              ).hasMatch(content)) {
                print('  Valid @DttBloc annotation found');
                foundFiles++;
                await _processFile(entity.path);
                generatedFiles +=
                    3; // Each file generates 3 files (state, event, cubit)
              } else {
                print('  @DttBloc found but not in valid format');
              }
            } else {
              print('  No @DttBloc annotation found');
            }
          }
        }
      } else {
        print('⚠️  lib directory not found at: ${libDir.path}');
      }

      // Process test directory if it exists
      final testDir = Directory(path.join(projectDir.path, 'test'));
      if (await testDir.exists()) {
        print('📂 Scanning test directory: ${testDir.path}');
        await for (final entity in testDir.list(recursive: true)) {
          if (entity is File && entity.path.endsWith('.dart')) {
            scannedFiles++;
            final relativePath = path.relative(
              entity.path,
              from: projectDir.path,
            );
            print('🔍 Scanning file: $relativePath');
            final content = await entity.readAsString();
            if (RegExp(r'@dttbloc', caseSensitive: false).hasMatch(content)) {
              print('  Found @DttBloc annotation in file');
              if (RegExp(
                r'@dttbloc\s*\(\)|@dttbloc\s*$|@dttbloc\s*[;{]',
                caseSensitive: false,
              ).hasMatch(content)) {
                print('  Valid @DttBloc annotation found');
                foundFiles++;
                await _processFile(entity.path);
                generatedFiles +=
                    3; // Each file generates 3 files (state, event, cubit)
              } else {
                print('  @DttBloc found but not in valid format');
              }
            } else {
              print('  No @DttBloc annotation found');
            }
          }
        }
      } else {
        print('ℹ️  test directory not found at: ${testDir.path}');
      }

      print('\n📊 Summary:');
      print('📊 Scanned $scannedFiles Dart files');
      print('📊 Found $foundFiles files with @dttBloc annotation');
      print('📊 Generated $generatedFiles bloc files');
    } finally {
      // Always restore original directory
      Directory.current = originalDir;
    }
  }

  /// Safely deletes existing bloc files, respecting DTT-DISABLE-MODIFY
  static Future<void> _cleanupExistingBlocFiles(String projectDir) async {
    // Process both lib and test directories
    for (final dirName in ['lib', 'test']) {
      final dir = Directory(path.join(projectDir, dirName));
      if (!await dir.exists()) continue;

      await for (final entity in dir.list(recursive: true)) {
        // Only process .bloc.*.g.dart files, not .dartantic.g.dart
        if (entity is File &&
            entity.path.contains('.bloc.') &&
            entity.path.endsWith('.g.dart') &&
            !entity.path.contains('.dartantic.g.dart')) {
          try {
            final content = await entity.readAsString();
            if (!content.contains('// DTT-DISABLE-MODIFY')) {
              await entity.delete();
              print(
                '🗑️  Deleted ${path.relative(entity.path, from: projectDir)}',
              );
            } else {
              print(
                '🔒 Skipping ${path.relative(entity.path, from: projectDir)} (DTT-DISABLE-MODIFY)',
              );
            }
          } catch (e) {
            print(
              '⚠️  Error processing ${path.relative(entity.path, from: projectDir)}: $e',
            );
          }
        }
      }
    }
  }

  /// Creates a new ASG instance with the standard bloc file header
  static ASG _createBlocFile(String originalFileName) {
    final asg = ASG();
    asg.addLine('// GENERATED BY DARTANTIC BLOC GENERATOR');
    asg.addLine('');
    asg.addLine("part of '$originalFileName.dart';");
    asg.addLine('');
    return asg;
  }

  /// Processes a single Dart file to generate its bloc
  static Future<void> _processFile(String filePath) async {
    // Skip generator code itself
    if (filePath.contains('blocGen/generators/') ||
        filePath.contains('blocGen/main.dart')) {
      return;
    }

    // Skip generated files
    if (filePath.endsWith('.g.dart')) {
      return;
    }

    final content = await File(filePath).readAsString();

    // Only process files with @DttBloc annotation (case insensitive)
    // Look for the exact annotation pattern
    if (!RegExp(r'@dttbloc', caseSensitive: false).hasMatch(content) ||
        !RegExp(
          r'@dttbloc\s*\(\)|@dttbloc\s*$|@dttbloc\s*[;{]',
          caseSensitive: false,
        ).hasMatch(content)) {
      return;
    }

    print('🔍 Processing ${path.relative(filePath)}');

    // Look for metadata file with correct extension
    final metadataPath = filePath.replaceAll('.dart', '.dartantic.g.dart');
    if (!await File(metadataPath).exists()) {
      print('⚠️  Skipping ${path.relative(filePath)} - no metadata file found');
      print('   Run "dart run dartantic gen" first to generate model files');
      return;
    }

    final metadata = await File(metadataPath).readAsString();
    final className = _extractClassName(metadata);
    if (className == null) {
      print(
        '⚠️  Skipping ${path.relative(filePath)} - could not extract class name from metadata',
      );
      return;
    }

    final fields = _extractFields(metadata);
    if (fields.isEmpty) {
      print(
        '⚠️  Skipping ${path.relative(filePath)} - no fields found in metadata',
      );
      return;
    }

    final originalFileName = path.basenameWithoutExtension(filePath);
    print('📦 Generating bloc for $className in ${path.relative(filePath)}');

    try {
      // Generate state file
      final stateGenerator = StateGenerator(
        className: className,
        fields: fields,
        originalFileName: originalFileName,
      );
      final stateAsg = _createBlocFile(originalFileName);
      stateAsg.add(stateGenerator.generate());
      final stateOutputPath = filePath.replaceAll(
        '.dart',
        '.bloc.state.g.dart',
      );
      await File(stateOutputPath).writeAsString(stateAsg.source);
      print('✅ Generated ${path.relative(stateOutputPath)}');

      // Generate event file
      final eventGenerator = EventGenerator(
        className: className,
        fields: fields,
        originalFileName: originalFileName,
      );
      final eventAsg = _createBlocFile(originalFileName);
      eventAsg.add(eventGenerator.generate());
      final eventOutputPath = filePath.replaceAll(
        '.dart',
        '.bloc.event.g.dart',
      );
      await File(eventOutputPath).writeAsString(eventAsg.source);
      print('✅ Generated ${path.relative(eventOutputPath)}');

      // Generate cubit file
      final cubitGenerator = CubitGenerator(
        className: className,
        fields: fields,
        originalFileName: originalFileName,
      );
      final cubitAsg = _createBlocFile(originalFileName);
      cubitAsg.add(cubitGenerator.generate());
      final cubitOutputPath = filePath.replaceAll(
        '.dart',
        '.bloc.cubit.g.dart',
      );
      await File(cubitOutputPath).writeAsString(cubitAsg.source);
      print('✅ Generated ${path.relative(cubitOutputPath)}');
    } catch (e) {
      print('❌ Error generating bloc for $className: $e');
      rethrow; // Rethrow to ensure we know if generation failed
    }
  }

  /// Extracts the class name from the metadata file
  static String? _extractClassName(String metadata) {
    // Look for the model meta constant
    final pattern = RegExp(r'const\s+DttModelMeta\s+_dtt_(\w+)_fieldMeta');
    final match = pattern.firstMatch(metadata);
    return match?.group(1);
  }

  /// Extracts fields from the metadata file
  static Map<String, String> _extractFields(String metadata) {
    final fields = <String, String>{};
    // Look for field definitions in the metadata
    final pattern = RegExp(r"'(\w+)':\s*DttFieldMeta\(\s*type:\s*'([^']+)'");
    for (final match in pattern.allMatches(metadata)) {
      final type = match.group(2)!;
      fields[match.group(1)!] = type;
    }
    return fields;
  }
}
