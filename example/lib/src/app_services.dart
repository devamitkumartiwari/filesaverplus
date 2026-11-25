import 'package:filesaverplus/filesaverplus.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'save_history.dart';

/// The plugin instance used by every page.
final FileSaverPlus fileSaver = FileSaverPlus();

/// Save results shared by every page.
final SaveHistory saveHistory = SaveHistory();

/// Runs a save, records the result in [saveHistory] and shows a snack bar.
///
/// Errors are caught and shown, never rethrown, so the example can't crash.
/// Returns the saved paths, or `null` if the save failed.
Future<List<String>?> runSave(
  BuildContext context,
  String title,
  Future<List<String>> Function() action,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final scheme = Theme.of(context).colorScheme;

  void show(String message, {bool isError = false}) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError ? scheme.error : null,
        ),
      );
  }

  void fail(List<String> lines, String message) {
    saveHistory.add(SaveRecord(title: title, lines: lines, isError: true));
    show(message, isError: true);
  }

  try {
    final paths = await action();
    saveHistory.add(SaveRecord(title: title, lines: paths));
    show(
      paths.length == 1
          ? '$title saved'
          : '$title: ${paths.length} files saved',
    );
    return paths;
  } on ArgumentError catch (e) {
    fail(['ArgumentError: ${e.message}'], 'Invalid input: ${e.message}');
  } on PlatformException catch (e) {
    fail([
      'PlatformException [${e.code}]',
      if (e.message != null) e.message!,
    ], 'Save failed (${e.code})');
  } catch (e) {
    fail(['$e'], 'Save failed');
  }
  return null;
}
