import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

/// Writes each file into the user's Downloads folder without overwriting
/// anything that is already there, and returns the final paths.
///
/// Shared by the Windows and Linux implementations.
Future<List<String>> writeToDownloads({
  required List<Uint8List> dataList,
  required List<String> fileNameList,
}) async {
  final downloadsDir = await getDownloadsDirectory();
  if (downloadsDir == null) {
    throw StateError('Could not locate the Downloads directory.');
  }
  if (!downloadsDir.existsSync()) {
    await downloadsDir.create(recursive: true);
  }

  final results = <String>[];
  for (var i = 0; i < dataList.length; i++) {
    final file = _uniqueFile(downloadsDir, fileNameList[i]);
    await file.writeAsBytes(dataList[i], flush: true);
    results.add(file.path);
  }
  return results;
}

/// Returns `dir/name`, or `dir/name (1).ext`, `dir/name (2).ext`, ... if a
/// file with that name already exists.
File _uniqueFile(Directory dir, String name) {
  final sep = Platform.pathSeparator;
  var file = File('${dir.path}$sep$name');
  if (!file.existsSync()) return file;

  final dot = name.lastIndexOf('.');
  final base = dot > 0 ? name.substring(0, dot) : name;
  final ext = dot > 0 ? name.substring(dot) : '';
  var n = 1;
  do {
    file = File('${dir.path}$sep$base ($n)$ext');
    n++;
  } while (file.existsSync());
  return file;
}
