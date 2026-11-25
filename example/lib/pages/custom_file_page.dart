import 'dart:convert';
import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';

import '../src/app_services.dart';
import '../src/save_history.dart';
import '../widgets/common.dart';

/// Build a file from scratch: name, MIME type and content.
///
/// Nothing is validated here on purpose, so you can see how the plugin
/// handles odd input: an empty name becomes `file`, `a/b.txt` becomes
/// `a_b.txt`, and empty content throws an `ArgumentError`.
class CustomFilePage extends StatefulWidget {
  const CustomFilePage({super.key});

  @override
  State<CustomFilePage> createState() => _CustomFilePageState();
}

class _CustomFilePageState extends State<CustomFilePage> {
  static const _mimeTypes = <String, String>{
    'text/plain': 'txt',
    'text/markdown': 'md',
    'text/csv': 'csv',
    'text/html': 'html',
    'application/json': 'json',
    'application/xml': 'xml',
  };

  final _name = TextEditingController(text: 'notes.md');
  final _content = TextEditingController(
    text: '# My notes\n\nWritten in the FileSaverPlus example app.\n',
  );
  String _mime = 'text/markdown';
  bool _busy = false;
  SaveRecord? _last;

  @override
  void dispose() {
    _name.dispose();
    _content.dispose();
    super.dispose();
  }

  void _pickMime(String? mime) {
    if (mime == null) return;
    setState(() {
      _mime = mime;
      // Keep the extension in step with the type, when there is a name.
      final name = _name.text;
      final dot = name.lastIndexOf('.');
      final base = dot > 0 ? name.substring(0, dot) : name;
      if (base.isNotEmpty) _name.text = '$base.${_mimeTypes[mime]}';
    });
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    await runSave(context, 'Custom file', () async {
      final path = await fileSaver.saveFile(
        Uint8List.fromList(utf8.encode(_content.text)),
        _name.text,
        _mime,
      );
      return [?path];
    });
    if (!mounted) return;
    setState(() {
      _busy = false;
      _last = saveHistory.records.firstOrNull;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom file')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          const SectionHeader('File'),
          TextField(
            controller: _name,
            decoration: const InputDecoration(
              labelText: 'File name',
              helperText: 'Try "a/b:c.txt" or leave it empty',
              prefixIcon: Icon(Icons.badge_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownMenu<String>(
            initialSelection: _mime,
            expandedInsets: EdgeInsets.zero,
            label: const Text('MIME type'),
            leadingIcon: const Icon(Icons.category_outlined),
            onSelected: _pickMime,
            dropdownMenuEntries: [
              for (final mime in _mimeTypes.keys)
                DropdownMenuEntry(value: mime, label: mime),
            ],
          ),
          const SectionHeader('Content'),
          TextField(
            controller: _content,
            minLines: 6,
            maxLines: 14,
            style: const TextStyle(fontFamily: 'monospace'),
            decoration: const InputDecoration(
              hintText: 'Leave empty to see the ArgumentError',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 24),
          SaveButton(label: 'Save file', busy: _busy, onPressed: _save),
          if (_last != null) ...[
            const SectionHeader('Result'),
            RecordCard(record: _last!),
          ],
        ],
      ),
    );
  }
}
