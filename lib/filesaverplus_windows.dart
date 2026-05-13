import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

import 'filesaverplus_platform_interface.dart';

/// Windows implementation of [FileSaverPlusPlatform] using dart:io.
class FileSaverPlusWindows extends FileSaverPlusPlatform {
  static void registerWith() {
    FileSaverPlusPlatform.instance = FileSaverPlusWindows();
  }

  @override
  Future<String?> get platformVersion async =>
      'Windows ${Platform.operatingSystemVersion}';

  @override
  Future<int?> get batteryPercentage async => null;

  @override
  Future<List<String>> saveMultipleFiles({
    required List<Uint8List> dataList,
    required List<String> fileNameList,
    required List<String> mimeTypeList,
  }) async {
    final downloadsDir = await getDownloadsDirectory();
    if (downloadsDir == null) {
      throw StateError('Could not locate the Downloads directory.');
    }

    final results = <String>[];

    for (int i = 0; i < dataList.length; i++) {
      final file = File(
        '${downloadsDir.path}${Platform.pathSeparator}${fileNameList[i]}',
      );
      await file.writeAsBytes(dataList[i], flush: true);
      results.add(file.path);
    }

    return results;
  }
}
