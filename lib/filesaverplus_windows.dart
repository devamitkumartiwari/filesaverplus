import 'dart:io';
import 'dart:typed_data';

import 'filesaverplus_platform_interface.dart';
import 'src/desktop_writer.dart';

/// Windows implementation of [FileSaverPlusPlatform] using `dart:io`.
///
/// Files are written to the user's Downloads folder. Existing files are never
/// overwritten; a ` (1)`, ` (2)`, ... suffix is added instead.
class FileSaverPlusWindows extends FileSaverPlusPlatform {
  /// Registers this class as the default [FileSaverPlusPlatform] instance.
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
  }) {
    return writeToDownloads(dataList: dataList, fileNameList: fileNameList);
  }
}
