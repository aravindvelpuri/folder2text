import 'dart:io';
import 'file_data.dart';
import 'path_utils.dart';

class FileUtils {
  static List<FileData> scanDirectory({
    required String rootPath,
    required bool includeHiddenFiles,
  }) {
    final List<FileData> files = [];
    final rootDir = Directory(rootPath);

    if (!rootDir.existsSync()) {
      return files;
    }

    for (final entity in rootDir.listSync(recursive: true)) {
      if (entity is! File) {
        continue;
      }

      final fileName = entity.uri.pathSegments.last;

      if (!includeHiddenFiles && fileName.startsWith('.')) {
        continue;
      }

      try {
        final content = entity.readAsStringSync();
        final relativePath = PathUtils.toRelativePath(
          rootPath: rootPath,
          fullPath: entity.path,
        );
        final normalizedPath = relativePath.replaceAll('\\', '/');
        
        // Get the last segment of the root path as the folder name
        final rootName = rootPath.split(Platform.pathSeparator).last;
        final fullPath = '$rootName/$normalizedPath';

        files.add(FileData(relativePath: fullPath, content: content));
      } catch (e) {
        continue;
      }
    }

    return files;
  }

  static String generateFileStructure(
    String rootPath,
    bool includeHiddenFiles,
  ) {
    final rootDir = Directory(rootPath);
    if (!rootDir.existsSync()) {
      return 'Directory does not exist.';
    }

    final buffer = StringBuffer();
    // Get folder name properly
    final folderName = _getFolderName(rootPath);
    buffer.writeln('📁 $folderName');

    _buildTreeStructure(buffer, rootDir, 0, includeHiddenFiles, rootPath);

    return buffer.toString();
  }

  static String _getFolderName(String path) {
    // Handle empty path
    if (path.isEmpty) return '';
    
    // Normalize path separators
    final normalizedPath = path.replaceAll('\\', '/');
    
    // Remove trailing slash if present
    final cleanPath = normalizedPath.endsWith('/') 
        ? normalizedPath.substring(0, normalizedPath.length - 1)
        : normalizedPath;
    
    // Get the last part of the path
    final segments = cleanPath.split('/');
    return segments.isNotEmpty ? segments.last : path;
  }

  static void _buildTreeStructure(
    StringBuffer buffer,
    Directory dir,
    int indent,
    bool includeHiddenFiles,
    String rootPath,
  ) {
    try {
      final entities = dir.listSync();
      final directories = <Directory>[];
      final files = <File>[];

      for (final entity in entities) {
        // Get the name from the path, not from URI
        final name = _getEntityName(entity.path);

        if (!includeHiddenFiles && name.startsWith('.')) {
          continue;
        }

        if (entity is Directory) {
          directories.add(entity);
        } else if (entity is File) {
          files.add(entity);
        }
      }

      // Sort by name
      directories.sort((a, b) => _getEntityName(a.path).compareTo(_getEntityName(b.path)));
      files.sort((a, b) => _getEntityName(a.path).compareTo(_getEntityName(b.path)));

      for (int i = 0; i < directories.length; i++) {
        final directory = directories[i];
        final name = _getEntityName(directory.path);
        final isLast = i == directories.length - 1 && files.isEmpty;
        final prefix = '${'    ' * indent}${isLast ? '└──' : '├──'}';
        
        buffer.writeln('$prefix 📁 $name/');
        _buildTreeStructure(buffer, directory, indent + 1, includeHiddenFiles, rootPath);
      }

      for (int i = 0; i < files.length; i++) {
        final file = files[i];
        final name = _getEntityName(file.path);
        final isLast = i == files.length - 1;
        final prefix = '${'    ' * indent}${isLast ? '└──' : '├──'}';
        final size = file.lengthSync();
        final sizeStr = _formatFileSize(size);

        buffer.writeln('$prefix 📄 $name ($sizeStr)');
      }
    } catch (e) {
      buffer.writeln('${'    ' * indent}└── [Error accessing directory]');
    }
  }

  static String _getEntityName(String path) {
    // Handle empty path
    if (path.isEmpty) return '';
    
    // Normalize path separators
    final normalizedPath = path.replaceAll('\\', '/');
    
    // Remove trailing slash if present
    final cleanPath = normalizedPath.endsWith('/') 
        ? normalizedPath.substring(0, normalizedPath.length - 1)
        : normalizedPath;
    
    // Get the last part of the path
    final segments = cleanPath.split('/');
    return segments.isNotEmpty ? segments.last : path;
  }

  static String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}