import 'package:flutter/services.dart';

import 'filesaverplus_platform_interface.dart';

/// macOS implementation of [FileSaverPlusPlatform] via MethodChannel.
///
/// Uses NSSavePanel on the native side so the user can choose where each file
/// is saved, mirroring the iOS share-sheet UX on the desktop.
class FileSaverPlusMacOS extends FileSaverPlusPlatform {
  static void registerWith() {
    FileSaverPlusPlatform.instance = FileSaverPlusMacOS();
  }

  final MethodChannel _channel = const MethodChannel('filesaverplus');

  @override
  Future<String?> get platformVersion async {
    return await _channel.invokeMethod<String>('getPlatformVersion');
  }

  @override
  Future<int?> get batteryPercentage async => null;

  @override
  Future<List<String>> saveMultipleFiles({
    required List<Uint8List> dataList,
    required List<String> fileNameList,
    required List<String> mimeTypeList,
  }) async {
    final result = await _channel.invokeMethod<List<dynamic>>(
      'saveMultipleFiles',
      {
        'dataList': dataList,
        'fileNameList': fileNameList,
        'mimeTypeList': mimeTypeList,
      },
    );
    return result?.cast<String>() ?? [];
  }
}
