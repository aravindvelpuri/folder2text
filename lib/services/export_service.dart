import 'dart:io';
import 'package:file_selector/file_selector.dart';

class ExportService {
  static Future<void> exportText({
    required String content,
    String defaultFileName = 'folder2text',
  }) async {
    if (content.isEmpty) {
      return;
    }

    try {
      final FileSaveLocation? saveLocation = await getSaveLocation(
        suggestedName: '$defaultFileName.txt',
        acceptedTypeGroups: const [
          XTypeGroup(label: 'Text Files', extensions: ['txt', 'md']),
        ],
      );

      if (saveLocation == null) {
        return;
      }

      final String path = saveLocation.path;
      final file = File(path);
      await file.writeAsString(content);
    } catch (e) {
      rethrow;
    }
  }
}