import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'filesaverplus_platform_interface.dart';

/// An implementation of [FileSaverPlusPlatform] that uses method channels.
///
/// Used on Android and iOS. Input validation and file-name de-duplication
/// happen in `FileSaverPlus` before this is called.
class MethodChannelFileSaverPlus extends FileSaverPlusPlatform {
  /// The method channel used to talk to the native platform.
  @visibleForTesting
  final MethodChannel methodChannel = const MethodChannel('filesaverplus');

  @override
  Future<String?> get platformVersion =>
      methodChannel.invokeMethod<String>('getPlatformVersion');

  @override
  Future<int?> get batteryPercentage =>
      methodChannel.invokeMethod<int>('getBatteryPercentage');

  @override
  Future<List<String>> saveMultipleFiles({
    required List<Uint8List> dataList,
    required List<String> fileNameList,
    required List<String> mimeTypeList,
  }) async {
    final result = await methodChannel.invokeListMethod<String>(
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
