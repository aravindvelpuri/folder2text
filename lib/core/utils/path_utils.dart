import 'dart:io';

class PathUtils {
  static String toRelativePath({
    required String rootPath,
    required String fullPath,
  }) {
    try {
      final normalizedRoot = rootPath.endsWith(Platform.pathSeparator)
          ? rootPath
          : '$rootPath${Platform.pathSeparator}';
      return fullPath.replaceFirst(normalizedRoot, '');
    } catch (e) {
      return fullPath;
    }
  }
}