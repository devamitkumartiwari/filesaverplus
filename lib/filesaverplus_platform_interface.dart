import 'dart:typed_data';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'filesaverplus_method_channel.dart';

abstract class FileSaverPlusPlatform extends PlatformInterface {
  FileSaverPlusPlatform() : super(token: _token);

  static final Object _token = Object();

  static FileSaverPlusPlatform _instance = MethodChannelFileSaverPlus();

  /// The default instance of [FileSaverPlusPlatform] to use.
  ///
  /// Defaults to [MethodChannelFileSaverPlus].
  static FileSaverPlusPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FileSaverPlusPlatform].
  static set instance(FileSaverPlusPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Returns the current platform version.
  Future<String?> get platformVersion {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  /// Returns the current battery percentage (0–100).
  Future<int?> get batteryPercentage {
    throw UnimplementedError('batteryPercentage() has not been implemented.');
  }

  /// Saves multiple files using platform-specific implementation.
  ///
  /// Returns a list of saved file paths (or identifiers) for each file.
  /// On iOS the paths are temporary staging locations; on Web they indicate
  /// that a browser download was triggered.
  ///
  /// [dataList]: List of file data in bytes.
  /// [fileNameList]: List of file names with extensions.
  /// [mimeTypeList]: List of corresponding MIME types.
  Future<List<String>> saveMultipleFiles({
    required List<Uint8List> dataList,
    required List<String> fileNameList,
    required List<String> mimeTypeList,
  }) {
    throw UnimplementedError('saveMultipleFiles() has not been implemented.');
  }
}
