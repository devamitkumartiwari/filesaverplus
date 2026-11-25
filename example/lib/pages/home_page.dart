import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import '../src/app_services.dart';
import '../widgets/common.dart';
import 'custom_file_page.dart';
import 'history_page.dart';
import 'multiple_files_page.dart';
import 'single_file_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _platform;
  int? _battery;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    String? platform;
    int? battery;
    try {
      platform = await fileSaver.platformVersion;
    } on Object {
      platform = null;
    }
    try {
      battery = await fileSaver.batteryPercentage;
    } on Object {
      battery = null;
    }
    if (!mounted) return;
    setState(() {
      _platform = platform ?? 'Unknown';
      _battery = battery;
      _loading = false;
    });
  }

  /// Where this platform puts saved files, in plain words.
  String _saveLocation() {
    if (kIsWeb) return 'Browser downloads';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        final major = int.tryParse(
          RegExp(r'(\d+)').firstMatch(_platform ?? '')?.group(1) ?? '',
        );
        if (major == null) return 'Downloads';
        return major >= 10 ? 'Public Downloads' : 'App folder › Download';
      case TargetPlatform.iOS:
        return 'Share sheet (you choose)';
      case TargetPlatform.macOS:
        return 'Save panel (you choose)';
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return 'Downloads';
      case TargetPlatform.fuchsia:
        return 'Unsupported';
    }
  }

  void _open(Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FileSaverPlus'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loading ? null : _refresh,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _StatusCard(
            platform: _loading ? '…' : _platform!,
            battery: _loading
                ? '…'
                : (_battery != null ? '$_battery%' : 'Not available'),
            location: _loading ? '…' : _saveLocation(),
          ),
          const SectionHeader('Features'),
          _FeatureTile(
            icon: Icons.insert_drive_file_outlined,
            title: 'Single file',
            subtitle: 'Save a text, HTML, JSON, CSV or PNG file',
            onTap: () => _open(const SingleFilePage()),
          ),
          _FeatureTile(
            icon: Icons.file_copy_outlined,
            title: 'Multiple files',
            subtitle: 'Save several files in one call, with duplicate names',
            onTap: () => _open(const MultipleFilesPage()),
          ),
          _FeatureTile(
            icon: Icons.edit_note_outlined,
            title: 'Custom file',
            subtitle: 'Type a name, pick a MIME type and write the content',
            onTap: () => _open(const CustomFilePage()),
          ),
          ListenableBuilder(
            listenable: saveHistory,
            builder: (context, _) => _FeatureTile(
              icon: Icons.history,
              title: 'History',
              subtitle: saveHistory.records.isEmpty
                  ? 'Saved paths and errors appear here'
                  : '${saveHistory.records.length} saves, '
                        '${saveHistory.successCount} succeeded',
              onTap: () => _open(const HistoryPage()),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.platform,
    required this.battery,
    required this.location,
  });

  final String platform;
  final String battery;
  final String location;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.devices_outlined, color: scheme.primary),
                const SizedBox(width: 8),
                Text('System status', style: text.titleMedium),
              ],
            ),
            const Divider(height: 24),
            InfoRow('Platform', platform),
            InfoRow('Battery', battery),
            InfoRow('Files are saved to', location),
            const SizedBox(height: 12),
            Chip(
              avatar: Icon(
                Icons.verified_user_outlined,
                color: scheme.onTertiaryContainer,
              ),
              label: Text(
                'No permissions required',
                style: TextStyle(color: scheme.onTertiaryContainer),
              ),
              side: BorderSide.none,
              backgroundColor: scheme.tertiaryContainer,
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card.outlined(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: scheme.primaryContainer,
          foregroundColor: scheme.onPrimaryContainer,
          child: Icon(icon),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
