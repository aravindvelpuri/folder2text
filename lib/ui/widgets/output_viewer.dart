import 'package:flutter/material.dart';

class OutputViewer extends StatefulWidget {
  final String text;

  const OutputViewer({super.key, required this.text});

  @override
  State<OutputViewer> createState() => _OutputViewerState();
}

class _OutputViewerState extends State<OutputViewer> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _listScrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    _listScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.text;

    if (text.isEmpty ||
        text == 'No output yet...' ||
        text == 'No files found.') {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'No output yet...\n\nSelect a folder to extract text from all files.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1A),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                _buildStatItem('Chars', '${text.length}'),
                const SizedBox(width: 16),
                _buildStatItem('KB', (text.length / 1024).toStringAsFixed(1)),
                const Spacer(),
                if (text.length > 50000)
                  Text(
                    'Large output - scroll to view',
                    style: TextStyle(color: Colors.orange[300], fontSize: 12),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: _buildTextContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTextContent() {
    final text = widget.text;
    final textStyle = const TextStyle(
      color: Colors.greenAccent,
      fontSize: 12,
      fontFamily: 'JetBrainsMono',
      height: 1.3,
    );

    if (text.length < 10000) {
      return Scrollbar(
        thumbVisibility: true,
        controller: _scrollController,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: SelectableText(text, style: textStyle),
        ),
      );
    }

    if (text.length < 50000) {
      return Scrollbar(
        thumbVisibility: true,
        controller: _scrollController,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: SelectableText(
            text,
            style: TextStyle(
              color: Colors.greenAccent,
              fontSize: 11,
              fontFamily: 'JetBrainsMono',
              height: 1.2,
            ),
          ),
        ),
      );
    }

    return _buildOptimizedLargeText();
  }

  Widget _buildOptimizedLargeText() {
    const chunkSize = 10000;
    final text = widget.text;
    final chunks = <String>[];

    for (int i = 0; i < text.length; i += chunkSize) {
      int end = i + chunkSize;
      if (end > text.length) end = text.length;
      chunks.add(text.substring(i, end));
    }

    return Scrollbar(
      thumbVisibility: true,
      controller: _listScrollController,
      child: ListView.builder(
        controller: _listScrollController,
        itemCount: chunks.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < chunks.length - 1 ? 8.0 : 0,
            ),
            child: SelectableText(
              chunks[index],
              style: const TextStyle(
                color: Colors.greenAccent,
                fontSize: 11,
                fontFamily: 'JetBrainsMono',
                height: 1.2,
              ),
            ),
          );
        },
      ),
    );
  }
}