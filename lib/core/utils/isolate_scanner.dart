import 'file_data.dart';
import 'file_utils.dart';

class IsolateScanParams {
  final String rootPath;
  final bool includeHiddenFiles;

  IsolateScanParams({required this.rootPath, required this.includeHiddenFiles});
}

List<FileData> isolateScan(IsolateScanParams params) {
  try {
    return FileUtils.scanDirectory(
      rootPath: params.rootPath,
      includeHiddenFiles: params.includeHiddenFiles,
    );
  } catch (e) {
    return [];
  }
}