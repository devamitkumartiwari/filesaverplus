import 'package:material_ui/material_ui.dart';

/// One save attempt, successful or not.
class SaveRecord {
  SaveRecord({
    required this.title,
    required this.lines,
    this.isError = false,
    DateTime? time,
  }) : time = time ?? DateTime.now();

  final String title;

  /// Saved paths on success, or the error details on failure.
  final List<String> lines;
  final bool isError;
  final DateTime time;
}

/// In-memory list of save attempts, shared by every page.
class SaveHistory extends ChangeNotifier {
  final List<SaveRecord> _records = [];

  List<SaveRecord> get records => List.unmodifiable(_records);

  int get successCount => _records.where((r) => !r.isError).length;

  void add(SaveRecord record) {
    _records.insert(0, record);
    notifyListeners();
  }

  void clear() {
    _records.clear();
    notifyListeners();
  }
}
