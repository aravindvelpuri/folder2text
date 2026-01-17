import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

class FolderPathField extends StatelessWidget {
  final String? folderPath;
  final void Function(String path) onBrowseSelected;

  const FolderPathField({
    super.key,
    required this.folderPath,
    required this.onBrowseSelected,
  });

  Future<void> _pickFolder() async {
    try {
      final String? path = await getDirectoryPath();

      if (path == null) return;

      final dir = Directory(path);
      if (dir.existsSync()) {
        onBrowseSelected(path);
      }
    } catch (e) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            readOnly: true,
            controller: TextEditingController(text: folderPath ?? ''),
            decoration: const InputDecoration(
              labelText: 'Selected Folder',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(onPressed: _pickFolder, child: const Text('Browse')),
      ],
    );
  }
}