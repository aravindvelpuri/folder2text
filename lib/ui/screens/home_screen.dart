import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

import '../../core/utils/file_data.dart';
import '../../core/utils/file_utils.dart';
import '../../core/utils/formatter.dart';
import '../../core/utils/isolate_scanner.dart';
import '../../services/export_service.dart';

import '../widgets/drop_zone.dart';
import '../widgets/folder_path_field.dart';
import '../widgets/action_buttons.dart';
import '../widgets/output_viewer.dart';
import '../widgets/options_panel.dart';
import '../widgets/structure_viewer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? selectedFolderPath;
  List<FileData> scannedFiles = [];
  String fileContentOutput = '';
  String fileStructureOutput = '';
  bool isLoading = false;
  bool _isBuildingFullOutput = false;
  bool _isFullOutputLoaded = false;
  bool _includeHiddenFiles = false;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> onFolderSelected(String path) async {
    setState(() {
      isLoading = true;
      _isBuildingFullOutput = false;
      _isFullOutputLoaded = false;
      selectedFolderPath = path;
      fileContentOutput = '';
      fileStructureOutput = '';
      scannedFiles = [];
    });

    final params = IsolateScanParams(
      rootPath: path,
      includeHiddenFiles: _includeHiddenFiles,
    );

    try {
      final files = await compute(isolateScan, params);

      if (files.isEmpty) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
          scannedFiles = files;
          fileContentOutput = 'No files found in selected folder.';
        });

        _showSnackBar('No files found in folder');
        return;
      }

      final previewOutput = await Formatter.buildOutput(
        files,
        fullOutput: false,
      );

      if (!mounted) return;

      setState(() {
        scannedFiles = files;
        fileContentOutput = previewOutput;
        isLoading = false;
        _isFullOutputLoaded = false;
      });

      _showFileCountSnackBar(files.length);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        fileContentOutput = 'Error: ${e.toString()}';
      });

      _showErrorSnackBar(e.toString());
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 4)),
    );
  }

  void _showFileCountSnackBar(int fileCount) {
    final snackBar = SnackBar(
      content: Text('Extracted $fileCount files'),
      duration: const Duration(seconds: 4),
      action: fileCount > 5
          ? SnackBarAction(
              label: 'Load Full',
              onPressed: () => _loadFullOutput(scannedFiles),
            )
          : null,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _showErrorSnackBar(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $error'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _loadFullOutput(List<FileData> files) async {
    setState(() {
      _isBuildingFullOutput = true;
    });

    try {
      final fullOutput = await Formatter.buildFullOutputForExport(files);

      if (!mounted) return;

      setState(() {
        fileContentOutput = fullOutput;
        _isBuildingFullOutput = false;
        _isFullOutputLoaded = true;
      });

      _showFullOutputSnackBar(fullOutput.length);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isBuildingFullOutput = false;
      });

      _showErrorSnackBar('Error loading full output: $e');
    }
  }

  void _showFullOutputSnackBar(int charCount) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Full output loaded ($charCount chars)'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> copyToClipboard() async {
    if (scannedFiles.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nothing to copy')));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final fullOutput = await Formatter.buildFullOutputForExport(scannedFiles);
      Clipboard.setData(ClipboardData(text: fullOutput));

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showCopySuccessSnackBar(scannedFiles.length, fullOutput.length);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showErrorSnackBar('Copy failed: ${e.toString()}');
    }
  }

  void _showCopySuccessSnackBar(int fileCount, int charCount) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Copied $fileCount files ($charCount chars) to clipboard',
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> exportOutput() async {
    if (scannedFiles.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nothing to export')));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      String exportOutputText;

      if (_currentTabIndex == 0) {
        // Export file content
        exportOutputText = await Formatter.buildFullOutputForExport(
          scannedFiles,
        );
      } else {
        // Export file structure
        exportOutputText = fileStructureOutput;
      }

      await ExportService.exportText(
        content: exportOutputText,
        defaultFileName: _currentTabIndex == 0
            ? 'folder2text_content'
            : 'folder2text_structure',
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showExportSuccessSnackBar(exportOutputText.length);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showErrorSnackBar('Export failed: ${e.toString()}');
    }
  }

  void _showExportSuccessSnackBar(int charCount) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('File exported successfully ($charCount chars)'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void clearOutput() {
    setState(() {
      fileContentOutput = '';
      fileStructureOutput = '';
      scannedFiles.clear();
      selectedFolderPath = null;
      _isFullOutputLoaded = false;
    });

    _showSnackBar('Output cleared');
  }

  Future<void> generateFileStructure() async {
    if (selectedFolderPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a folder first')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final structure = await compute(
        (params) => FileUtils.generateFileStructure(
          params['rootPath'] as String,
          params['includeHidden'] as bool,
        ),
        {'rootPath': selectedFolderPath!, 'includeHidden': _includeHiddenFiles},
      );

      if (!mounted) return;

      setState(() {
        fileStructureOutput = structure;
        isLoading = false;
        // Switch to structure tab
        _tabController.animateTo(1);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File structure generated'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        fileStructureOutput = 'Error generating file structure: $e';
      });
    }
  }

  Future<void> copyCurrentOutput() async {
    String textToCopy;

    if (_currentTabIndex == 0) {
      // Copy file content
      if (scannedFiles.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Nothing to copy')));
        return;
      }

      setState(() {
        isLoading = true;
      });

      try {
        final fullOutput = await Formatter.buildFullOutputForExport(
          scannedFiles,
        );
        textToCopy = fullOutput;
      } catch (e) {
        if (!mounted) return;
        setState(() {
          isLoading = false;
        });
        _showErrorSnackBar('Copy failed: ${e.toString()}');
        return;
      }
    } else {
      // Copy file structure
      if (fileStructureOutput.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Generate file structure first')),
        );
        return;
      }
      textToCopy = fileStructureOutput;
    }

    try {
      await Clipboard.setData(ClipboardData(text: textToCopy));

      if (_currentTabIndex == 0) {
        setState(() {
          isLoading = false;
        });

        _showCopySuccessSnackBar(scannedFiles.length, textToCopy.length);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File structure copied to clipboard'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (_currentTabIndex == 0) {
        setState(() {
          isLoading = false;
        });
      }

      _showErrorSnackBar('Failed to copy: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropZone(onFolderDropped: onFolderSelected),
              const SizedBox(height: 12),
              FolderPathField(
                folderPath: selectedFolderPath,
                onBrowseSelected: onFolderSelected,
              ),
              const SizedBox(height: 12),
              OptionsPanel(
                includeHiddenFiles: _includeHiddenFiles,
                onIncludeHiddenChanged: (value) {
                  setState(() {
                    _includeHiddenFiles = value;
                  });
                },
                onGenerateStructure: generateFileStructure,
                hasStructure: fileStructureOutput.isNotEmpty,
              ),
              const SizedBox(height: 12),
              ActionButtons(
                onCopy: copyCurrentOutput,
                onExport: exportOutput,
                onClear: clearOutput,
                onLoadFull:
                    scannedFiles.isNotEmpty &&
                        !_isFullOutputLoaded &&
                        _currentTabIndex == 0
                    ? () => _loadFullOutput(scannedFiles)
                    : null,
                hasOutput:
                    (fileContentOutput.isNotEmpty &&
                        fileContentOutput != 'No output yet...') ||
                    fileStructureOutput.isNotEmpty,
                hasScannedFiles: scannedFiles.isNotEmpty,
                isFullOutputLoaded: _isFullOutputLoaded,
                currentTabIndex: _currentTabIndex,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 500,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade500,
                              Colors.blue.shade700,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicatorPadding: const EdgeInsets.all(4),
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.grey[700],
                        labelStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        tabs: [
                          Tab(
                            icon: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: _currentTabIndex == 0
                                    ? Colors.white.withValues(alpha: 0.2)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.description, size: 18),
                                  SizedBox(width: 6),
                                  Text('File Content'),
                                ],
                              ),
                            ),
                          ),
                          Tab(
                            icon: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: _currentTabIndex == 1
                                    ? Colors.white.withValues(alpha: 0.2)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.format_list_numbered_rtl_outlined,
                                    size: 18,
                                  ),
                                  SizedBox(width: 6),
                                  Text('File Structure'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.grey[200]!,
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              // File Content Tab
                              Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.blue.shade50,
                                          Colors.white,
                                          Colors.blue.shade50,
                                        ],
                                      ),
                                    ),
                                    child: OutputViewer(
                                      text: fileContentOutput,
                                    ),
                                  ),
                                  if (isLoading && _currentTabIndex == 0)
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.blue.shade100.withValues(
                                              alpha: 0.9,
                                            ),
                                            Colors.blue.shade50.withValues(
                                              alpha: 0.9,
                                            ),
                                          ],
                                        ),
                                      ),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(20),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.blue
                                                        .withValues(alpha: 0.2),
                                                    blurRadius: 10,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  CircularProgressIndicator(
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(Colors.blue.shade700),
                                                    strokeWidth: 4,
                                                  ),
                                                  const SizedBox(height: 16),
                                                  Text(
                                                    _isBuildingFullOutput
                                                        ? 'Building full output...'
                                                        : 'Scanning files...',
                                                    style: TextStyle(
                                                      color: Colors.blue[900],
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  if (scannedFiles.isNotEmpty &&
                                                      !isLoading)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            top: 8.0,
                                                          ),
                                                      child: Text(
                                                        'Processing ${scannedFiles.length} files...',
                                                        style: TextStyle(
                                                          color:
                                                              Colors.blue[700],
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              // File Structure Tab
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.green.shade50,
                                      Colors.white,
                                      Colors.green.shade50,
                                    ],
                                  ),
                                ),
                                child: StructureViewer(
                                  text: fileStructureOutput,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
