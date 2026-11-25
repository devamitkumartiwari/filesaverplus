import 'package:material_ui/material_ui.dart';

import '../src/app_services.dart';
import '../src/samples.dart';
import '../src/save_history.dart';
import '../widgets/common.dart';

/// Pick several sample files and save them with one `saveMultipleFiles` call.
class MultipleFilesPage extends StatefulWidget {
  const MultipleFilesPage({super.key});

  @override
  State<MultipleFilesPage> createState() => _MultipleFilesPageState();
}

class _MultipleFilesPageState extends State<MultipleFilesPage> {
  final Set<SampleFile> _selected = {...sampleFiles.take(3)};
  bool _twice = false;
  bool _busy = false;
  SaveRecord? _last;

  /// The files to send, in list order. With "twice" on, each file appears two
  /// times, so the plugin has to rename the copies (`hello_2.txt`).
  List<SampleFile> get _ordered {
    final files = sampleFiles.where(_selected.contains).toList();
    return _twice ? [...files, ...files] : files;
  }

  Future<void> _save() async {
    final files = _ordered;
    setState(() => _busy = true);
    await runSave(
      context,
      '${files.length} files',
      () => fileSaver.saveMultipleFiles(
        dataList: [for (final f in files) f.build()],
        fileNameList: [for (final f in files) f.fileName],
        mimeTypeList: [for (final f in files) f.mimeType],
      ),
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _last = saveHistory.records.firstOrNull;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final count = _ordered.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Multiple files'),
        actions: [
          TextButton(
            onPressed: () => setState(() {
              if (_selected.length == sampleFiles.length) {
                _selected.clear();
              } else {
                _selected.addAll(sampleFiles);
              }
            }),
            child: Text(
              _selected.length == sampleFiles.length ? 'None' : 'All',
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          const SectionHeader('Files'),
          Card.outlined(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (final sample in sampleFiles)
                  CheckboxListTile(
                    value: _selected.contains(sample),
                    onChanged: (v) => setState(
                      () => v == true
                          ? _selected.add(sample)
                          : _selected.remove(sample),
                    ),
                    secondary: Icon(sample.icon, color: scheme.primary),
                    title: Text(sample.fileName),
                    subtitle: Text(sample.mimeType),
                  ),
              ],
            ),
          ),
          const SectionHeader('Options'),
          Card.outlined(
            clipBehavior: Clip.antiAlias,
            child: SwitchListTile(
              value: _twice,
              onChanged: (v) => setState(() => _twice = v),
              title: const Text('Save each file twice'),
              subtitle: const Text(
                'Shows duplicate handling: hello.txt, then hello_2.txt',
              ),
            ),
          ),
          const SizedBox(height: 24),
          SaveButton(
            label: count == 0
                ? 'Select at least one file'
                : 'Save $count file${count == 1 ? '' : 's'}',
            busy: _busy,
            onPressed: count == 0 ? null : _save,
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
