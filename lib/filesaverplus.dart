import 'dart:typed_data';

import 'filesaverplus_platform_interface.dart';
import 'src/file_request.dart';

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

/// Saves files to the user's device. No permissions are required on any
/// platform.
///
/// ```dart
/// final path = await FileSaverPlus().saveFile(bytes, 'report.pdf', 'application/pdf');
/// ```
class FileSaverPlus {
  /// Returns the platform name and OS version, e.g. `Android 14`.
  Future<String?> get platformVersion =>
      FileSaverPlusPlatform.instance.platformVersion;

  /// Returns the device battery percentage (0–100) on Android and iOS, or
  /// `null` on other platforms.
  Future<int?> get batteryPercentage =>
      FileSaverPlusPlatform.instance.batteryPercentage;

  /// Saves several files in one call and returns one entry per file.
  ///
  /// What each entry is depends on the platform:
  ///
  /// * **Android 10+**: a `content://` URI in the public Downloads folder.
  /// * **Android 7–9**: an absolute path in the app-specific Downloads folder
  ///   (`Android/data/<package>/files/Download`).
  /// * **iOS**: the temporary staging path handed to the share sheet.
  /// * **macOS**: the path the user picked, or `cancelled:<fileName>`.
  /// * **Web**: `download_triggered:<fileName>`.
  /// * **Windows / Linux**: the absolute path in the Downloads folder.
  ///
  /// File names are sanitized, and duplicates within one call are renamed
  /// (`data.txt`, `data_2.txt`, ...).
  ///
  /// Throws [ArgumentError] if the lists differ in length or an entry has
  /// empty data or an empty MIME type. Native failures surface as a
  /// `PlatformException`.
  Future<List<String>> saveMultipleFiles({
    required List<Uint8List> dataList,
    required List<String> fileNameList,
    required List<String> mimeTypeList,
  }) async {
    final names = prepareFileNames(
      dataList: dataList,
      fileNameList: fileNameList,
      mimeTypeList: mimeTypeList,
    );
    if (dataList.isEmpty) return const <String>[];
    return FileSaverPlusPlatform.instance.saveMultipleFiles(
      dataList: dataList,
      fileNameList: names,
      mimeTypeList: mimeTypeList,
    );
  }

  /// Saves a single file and returns its saved path or URI.
  ///
  /// See [saveMultipleFiles] for what the returned value means per platform.
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
