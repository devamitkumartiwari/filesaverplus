import 'package:material_ui/material_ui.dart';

import '../src/app_services.dart';
import '../widgets/common.dart';

/// Every save attempt from this session, newest first.
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: saveHistory,
      builder: (context, _) {
        final records = saveHistory.records;
        return Scaffold(
          appBar: AppBar(
            title: const Text('History'),
            actions: [
              if (records.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_sweep_outlined),
                  tooltip: 'Clear history',
                  onPressed: saveHistory.clear,
                ),
            ],
          ),
          body: records.isEmpty
              ? const _EmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  itemCount: records.length,
                  itemBuilder: (_, i) => RecordCard(record: records[i]),
                ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 64, color: scheme.outline),
            const SizedBox(height: 16),
            Text('Nothing saved yet', style: text.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Saved paths and errors from every page appear here.',
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
