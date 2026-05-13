import 'dart:typed_data';

import 'filesaverplus_platform_interface.dart';

// Conditionally export Linux and Windows which use dart:io
export 'filesaverplus_linux.dart'
    if (dart.library.js_interop) 'filesaverplus_linux_stub.dart';
export 'filesaverplus_macos.dart';
export 'filesaverplus_platform_interface.dart';
// Conditionally export Web which uses flutter_web_plugins
export 'filesaverplus_web.dart'
    if (dart.library.io) 'filesaverplus_web_stub.dart';
export 'filesaverplus_windows.dart'
    if (dart.library.js_interop) 'filesaverplus_windows_stub.dart';

class FileSaverPlus {
  /// Returns the platform OS version string from the native side.
  Future<String?> get platformVersion =>
      FileSaverPlusPlatform.instance.platformVersion;

  /// Returns the device battery percentage (0–100) from the native side.
  Future<int?> get batteryPercentage =>
      FileSaverPlusPlatform.instance.batteryPercentage;

  /// Saves multiple files and returns the list of saved file paths.
  ///
  /// On Android, paths are the actual locations in the Downloads folder.
  /// On iOS, paths are temporary staging locations used before the share sheet.
  /// On Web, each entry is `"download_triggered:<filename>"`.
  /// On Windows/Linux/macOS, paths are the actual saved file locations.
  Future<List<String>> saveMultipleFiles({
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

  /// Saves a single file and returns its saved path.
  Future<String?> saveFile(
    Uint8List data,
    String fileName,
    String mimeType,
  ) async {
    final paths = await saveMultipleFiles(
      dataList: [data],
      fileNameList: [fileName],
      mimeTypeList: [mimeType],
    );
    return paths.isNotEmpty ? paths.first : null;
  }
}
