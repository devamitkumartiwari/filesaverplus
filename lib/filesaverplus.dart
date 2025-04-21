import 'dart:typed_data';
import 'filesaverplus_platform_interface.dart';

class FileSaverPlus {
  /// Returns the platform version from the native side.
  Future<String?> get platformVersion =>
      FileSaverPlusPlatform.instance.platformVersion;

  /// Returns the battery percentage from the native side.
  Future<int?> get batteryPercentage =>
      FileSaverPlusPlatform.instance.batteryPercentage;

  /// Saves multiple files by delegating to the platform-specific implementation.
  Future<void> saveMultipleFiles({
    required List<Uint8List> dataList,
    required List<String> fileNameList,
    required List<String> mimeTypeList,
  }) {
    return FileSaverPlusPlatform.instance.saveMultipleFiles(
      dataList: dataList,
      fileNameList: fileNameList,
      mimeTypeList: mimeTypeList,
    );
  }

  /// Saves a single file by internally using the multiple files method.
  Future<void> saveFile(
      Uint8List data,
      String fileName,
      String mimeType,
      ) {
    return saveMultipleFiles(
      dataList: [data],
      fileNameList: [fileName],
      mimeTypeList: [mimeType],
    );
  }
}
