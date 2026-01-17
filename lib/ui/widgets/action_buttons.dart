import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onCopy;
  final VoidCallback onExport;
  final VoidCallback onClear;
  final VoidCallback? onLoadFull;
  final bool hasOutput;
  final bool hasScannedFiles;
  final bool isFullOutputLoaded;
  final int currentTabIndex;

  const ActionButtons({
    super.key,
    required this.onCopy,
    required this.onExport,
    required this.onClear,
    this.onLoadFull,
    required this.hasOutput,
    required this.hasScannedFiles,
    required this.isFullOutputLoaded,
    required this.currentTabIndex,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = currentTabIndex == 0 ? Colors.blue : Colors.green;
    final lightColor = currentTabIndex == 0
        ? Colors.blue.shade50
        : Colors.green.shade50;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: lightColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildActionButton(
                icon: Icons.save,
                label: currentTabIndex == 0
                    ? 'Export Content (.txt)'
                    : 'Export Structure (.txt)',
                onPressed: hasOutput ? onExport : null,
                color: primaryColor,
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                icon: Icons.copy,
                label: currentTabIndex == 0
                    ? 'Copy All Text'
                    : 'Copy Structure',
                onPressed: hasOutput ? onCopy : null,
                color: primaryColor,
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                icon: Icons.clear,
                label: 'Clear',
                onPressed: hasOutput ? onClear : null,
                color: Colors.grey,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (onLoadFull != null &&
            hasScannedFiles &&
            !isFullOutputLoaded &&
            currentTabIndex == 0)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue.shade200, width: 1.5),
              ),
              child: OutlinedButton.icon(
                onPressed: onLoadFull,
                icon: Icon(
                  Icons.fullscreen,
                  size: 16,
                  color: Colors.blue.shade700,
                ),
                label: Text(
                  'Load Full Output in Viewer',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
          ),
        if (isFullOutputLoaded && currentTabIndex == 0)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green.shade700,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Full output loaded',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: 18,
        color: onPressed != null ? color : Colors.grey,
      ),
      label: Text(
        label,
        style: TextStyle(
          color: onPressed != null ? color : Colors.grey,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: color,
        elevation: onPressed != null ? 2 : 0,
        shadowColor: color.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: onPressed != null
                ? color.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    );
  }
}
