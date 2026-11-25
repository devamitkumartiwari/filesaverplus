import 'package:flutter/services.dart';

import 'filesaverplus_platform_interface.dart';

/// macOS implementation of [FileSaverPlusPlatform] via a method channel.
///
/// Shows an `NSSavePanel` for each file so the user chooses where it goes.
/// A file the user cancels is reported as `cancelled:<fileName>`.
class FileSaverPlusMacOS extends FileSaverPlusPlatform {
  /// Registers this class as the default [FileSaverPlusPlatform] instance.
  static void registerWith() {
    FileSaverPlusPlatform.instance = FileSaverPlusMacOS();
  }

  final MethodChannel _channel = const MethodChannel('filesaverplus');

  @override
  Future<String?> get platformVersion =>
      _channel.invokeMethod<String>('getPlatformVersion');

  @override
  Future<int?> get batteryPercentage async => null;

  @override
  Future<List<String>> saveMultipleFiles({
    required List<Uint8List> dataList,
    required List<String> fileNameList,
    required List<String> mimeTypeList,
  }) async {
    final result = await _channel.invokeListMethod<String>(
      'saveMultipleFiles',
      <String, Object>{
        'dataList': dataList,
        'fileNameList': fileNameList,
        'mimeTypeList': mimeTypeList,
      },
    );
    return result ?? const <String>[];
  }
}
