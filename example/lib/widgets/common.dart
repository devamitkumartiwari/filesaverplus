import 'package:material_ui/material_ui.dart';

import '../src/save_history.dart';

/// Small coloured title above a group of widgets.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 24, 4, 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall
            ?.copyWith(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}

/// Label on the left, value on the right.
class InfoRow extends StatelessWidget {
  const InfoRow(this.label, this.value, {super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows one [SaveRecord]: a title with a status icon, then each saved path
/// (or the error details) in monospace.
class RecordCard extends StatelessWidget {
  const RecordCard({super.key, required this.record});

  final SaveRecord record;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final accent = record.isError ? scheme.error : scheme.primary;
    final time = TimeOfDay.fromDateTime(record.time).format(context);

    return Card.filled(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: record.isError
          ? scheme.errorContainer
          : scheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  record.isError
                      ? Icons.error_outline
                      : Icons.check_circle_outline,
                  size: 18,
                  color: accent,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    record.title,
                    style: text.labelLarge?.copyWith(color: accent),
                  ),
                ),
                Text(
                  time,
                  style: text.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            for (final line in record.lines)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: SelectableText(
                  line,
                  style: text.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    color: record.isError
                        ? scheme.onErrorContainer
                        : scheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Primary call-to-action that shows a spinner while [busy].
class SaveButton extends StatelessWidget {
  const SaveButton({
    super.key,
    required this.label,
    required this.busy,
    required this.onPressed,
    this.icon = Icons.download_outlined,
  });

  final String label;
  final bool busy;
  final VoidCallback? onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: busy ? null : onPressed,
        icon: busy
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon),
        label: Text(label),
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
      ),
    );
  }
}
