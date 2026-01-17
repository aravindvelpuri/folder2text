import 'dart:io';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';

class DropZone extends StatefulWidget {
  final void Function(String path) onFolderDropped;

  const DropZone({super.key, required this.onFolderDropped});

  @override
  State<DropZone> createState() => _DropZoneState();
}

class _DropZoneState extends State<DropZone> {
  bool isDragging = false;

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragEntered: (_) => setState(() => isDragging = true),
      onDragExited: (_) => setState(() => isDragging = false),
      onDragDone: (details) {
        setState(() => isDragging = false);

        if (details.files.isEmpty) return;

        final path = details.files.first.path;
        final dir = Directory(path);

        if (dir.existsSync()) {
          widget.onFolderDropped(path);
        }
      },
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          border: Border.all(
            color: isDragging ? Colors.blue : Colors.blueGrey,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isDragging
              ? Colors.blue.withValues(alpha: 0.05)
              : Colors.white,
        ),
        child: const Center(
          child: Text(
            '📂 Drag & Drop Folder Here\nor click Browse',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}