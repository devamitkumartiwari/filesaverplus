import 'dart:convert';
import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';

import '../src/app_services.dart';
import '../src/samples.dart';
import '../src/save_history.dart';
import '../widgets/common.dart';

/// Pick one sample file, preview it and save it with `saveFile`.
class SingleFilePage extends StatefulWidget {
  const SingleFilePage({super.key});

  @override
  State<SingleFilePage> createState() => _SingleFilePageState();
}

class _SingleFilePageState extends State<SingleFilePage> {
  SampleFile _selected = sampleFiles.first;
  late Uint8List _bytes = _selected.build();
  bool _busy = false;
  SaveRecord? _last;

  void _select(SampleFile sample) {
    setState(() {
      _selected = sample;
      _bytes = sample.build();
    });
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    await runSave(context, '${_selected.label} file', () async {
      final path = await fileSaver.saveFile(
        _selected.build(),
        _selected.fileName,
        _selected.mimeType,
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
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final isImage = _selected.mimeType.startsWith('image/');

    return Scaffold(
      appBar: AppBar(title: const Text('Single file')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          const SectionHeader('File type'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final sample in sampleFiles)
                ChoiceChip(
                  avatar: Icon(sample.icon),
                  label: Text(sample.label),
                  selected: sample == _selected,
                  onSelected: (_) => _select(sample),
                ),
            ],
          ),
          const SectionHeader('Preview'),
          Card.outlined(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoRow('File name', _selected.fileName),
                  InfoRow('MIME type', _selected.mimeType),
                  InfoRow('Size', '${_bytes.length} bytes'),
                  const Divider(height: 24),
                  if (isImage)
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          _bytes,
                          width: 96,
                          height: 96,
                          filterQuality: FilterQuality.none,
                        ),
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        utf8.decode(_bytes, allowMalformed: true),
                        maxLines: 10,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SaveButton(
            label: 'Save ${_selected.fileName}',
            busy: _busy,
            onPressed: _save,
          ),
          if (_last != null) ...[
            const SectionHeader('Result'),
            RecordCard(record: _last!),
          ],
        ],
      ),
    );
  }
}
