import 'package:flutter/foundation.dart';
import 'file_data.dart';

class Formatter {
  static Future<String> buildOutput(
    List<FileData> files, {
    bool fullOutput = false,
  }) async {
    if (files.isEmpty) return 'No files found.';

    if (fullOutput || files.length <= 5) {
      return await compute(_buildFullOutput, files);
    }

    if (files.length <= 15) {
      return await compute(_buildMediumPreview, files);
    }

    return await compute(_buildLimitedPreview, files);
  }

  static String _buildLimitedPreview(List<FileData> files) {
    final buffer = StringBuffer();

    int totalChars = 0;
    int filesShown = 0;
    const maxFilesToShow = 8;
    const maxTotalChars = 25000;

    for (int i = 0; i < files.length && i < maxFilesToShow; i++) {
      final file = files[i];

      // Directly write the path and content without emoji
      buffer.writeln(file.relativePath);
      buffer.writeln(file.content);

      totalChars += file.relativePath.length + file.content.length;
      filesShown++;

      if (totalChars > maxTotalChars) {
        break;
      }

      if (i < files.length - 1 && i < maxFilesToShow - 1) {
        if (!file.content.endsWith('\n')) {
          buffer.writeln();
        }
        buffer.writeln();
      }
    }

    if (files.length > maxFilesToShow || totalChars >= maxTotalChars) {
      buffer.writeln('\n\n=== PREVIEW ONLY ===');
      buffer.writeln('Total files in folder: ${files.length}');
      buffer.writeln('Files shown in preview: $filesShown');
      
      if (files.length > maxFilesToShow) {
        buffer.writeln('\nOther files:');
        for (int i = maxFilesToShow; i < files.length && i < maxFilesToShow + 10; i++) {
          buffer.writeln('  ${files[i].relativePath}');
        }
        if (files.length > maxFilesToShow + 10) {
          buffer.writeln('  ... and ${files.length - maxFilesToShow - 10} more');
        }
      }
    }

    return buffer.toString();
  }

  static String _buildMediumPreview(List<FileData> files) {
    final buffer = StringBuffer();

    int totalChars = 0;
    const maxTotalChars = 50000;

    for (int i = 0; i < files.length; i++) {
      final file = files[i];

      buffer.writeln(file.relativePath);
      buffer.writeln(file.content);

      totalChars += file.relativePath.length + file.content.length;

      if (totalChars > maxTotalChars) {
        break;
      }

      if (i < files.length - 1) {
        if (!file.content.endsWith('\n')) buffer.writeln();
        buffer.writeln();
      }
    }

    if (totalChars >= maxTotalChars) {
      buffer.writeln('\n\n=== PREVIEW TRUNCATED ===');
      buffer.writeln('Total files: ${files.length}');
    }

    return buffer.toString();
  }

  static String _buildFullOutput(List<FileData> files) {
    final buffer = StringBuffer();

    for (int i = 0; i < files.length; i++) {
      final file = files[i];

      buffer.writeln(file.relativePath);
      buffer.writeln(file.content);

      if (!file.content.endsWith('\n')) {
        buffer.writeln();
      }

      if (i < files.length - 1) {
        buffer.writeln();
      }
    }

    return buffer.toString();
  }

  static Future<String> buildFullOutputForExport(List<FileData> files) async {
    return await compute(_buildFullOutput, files);
  }
}