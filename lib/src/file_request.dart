import 'dart:typed_data';

/// Characters that are not allowed in a file name on at least one supported
/// platform (Windows is the strictest), plus ASCII control characters.
final RegExp _illegalFileNameChars = RegExp(r'[\\/:*?"<>|\x00-\x1F\x7F]');

/// Replaces characters that are illegal in file names with `_`, trims
/// surrounding whitespace and dots, and falls back to `file` when nothing
/// usable is left.
String sanitizeFileName(String name) {
  var cleaned = name.replaceAll(_illegalFileNameChars, '_').trim();
  // Leading/trailing dots produce hidden files or are stripped by Windows.
  cleaned = cleaned.replaceAll(RegExp(r'^\.+|\.+$'), '').trim();
  return cleaned.isEmpty ? 'file' : cleaned;
}

/// Validates the three parallel lists passed to `saveMultipleFiles` and
/// returns sanitized, de-duplicated file names.
///
/// Duplicate names get a numeric suffix before the extension:
/// `data.txt`, `data_2.txt`, `data_3.txt`, ...
///
/// Throws [ArgumentError] when the lists differ in length, or when any entry
/// has empty data or an empty MIME type.
List<String> prepareFileNames({
  required List<Uint8List> dataList,
  required List<String> fileNameList,
  required List<String> mimeTypeList,
}) {
  if (dataList.length != fileNameList.length ||
      dataList.length != mimeTypeList.length) {
    throw ArgumentError(
      'dataList, fileNameList and mimeTypeList must have the same length '
      '(got ${dataList.length}, ${fileNameList.length}, '
      '${mimeTypeList.length}).',
    );
  }

  for (var i = 0; i < dataList.length; i++) {
    if (dataList[i].isEmpty) {
      throw ArgumentError.value(dataList[i], 'dataList[$i]', 'Data is empty.');
    }
    if (mimeTypeList[i].trim().isEmpty) {
      throw ArgumentError.value(
        mimeTypeList[i],
        'mimeTypeList[$i]',
        'MIME type is empty.',
      );
    }
  }

  final used = <String>{};
  final counts = <String, int>{};
  final result = <String>[];

  for (final original in fileNameList) {
    final name = sanitizeFileName(original);
    var candidate = name;
    if (used.contains(candidate.toLowerCase())) {
      final dot = name.lastIndexOf('.');
      final base = dot > 0 ? name.substring(0, dot) : name;
      final ext = dot > 0 ? name.substring(dot) : '';
      var n = counts[name.toLowerCase()] ?? 1;
      do {
        n++;
        candidate = '${base}_$n$ext';
      } while (used.contains(candidate.toLowerCase()));
      counts[name.toLowerCase()] = n;
    }
    used.add(candidate.toLowerCase());
    result.add(candidate);
  }

  return result;
}
