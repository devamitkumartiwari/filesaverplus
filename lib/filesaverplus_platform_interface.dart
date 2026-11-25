import 'dart:typed_data';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'filesaverplus_method_channel.dart';

/// The interface that platform implementations of filesaverplus extend.
abstract class FileSaverPlusPlatform extends PlatformInterface {
  /// Constructs a FileSaverPlusPlatform.
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

  /// Saves multiple files using the platform-specific implementation.
  ///
  /// Returns one entry per file. See `FileSaverPlus.saveMultipleFiles` for
  /// what each entry means on each platform.
  ///
  /// [dataList]: file contents. [fileNameList]: file names with extensions.
  /// [mimeTypeList]: matching MIME types. All three have the same length and
  /// have already been validated by `FileSaverPlus`.
  Future<List<String>> saveMultipleFiles({
    required List<Uint8List> dataList,
    required List<String> fileNameList,
    required List<String> mimeTypeList,
  }) {
    throw UnimplementedError('saveMultipleFiles() has not been implemented.');
  }
}
