import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'filesaverplus_platform_interface.dart';

/// An implementation of [FileSaverPlusPlatform] that uses method channels.
class MethodChannelFileSaverPlus extends FileSaverPlusPlatform {
  @visibleForTesting
  final MethodChannel methodChannel = const MethodChannel('filesaverplus');

  @override
  Future<String?> get platformVersion async {
    return await methodChannel.invokeMethod<String>('getPlatformVersion');
  }

  @override
  Future<int?> get batteryPercentage async {
    return await methodChannel.invokeMethod<int>('getBatteryPercentage');
  }

  @override
  Future<List<String>> saveMultipleFiles({
    required List<Uint8List> dataList,
    required List<String> fileNameList,
    required List<String> mimeTypeList,
  }) async {
    if (dataList.length != fileNameList.length ||
        dataList.length != mimeTypeList.length) {
      throw ArgumentError('All input lists must have the same length.');
    }

    for (int i = 0; i < dataList.length; i++) {
      if (dataList[i].isEmpty) {
        throw ArgumentError('Data at index $i is empty.');
      }
    }

    for (int i = 0; i < mimeTypeList.length; i++) {
      if (mimeTypeList[i].trim().isEmpty) {
        throw ArgumentError('MIME type at index $i is empty.');
      }
    }

    // Ensure unique filenames by appending a counter to duplicates.
    final Map<String, int> fileNameCount = {};
    final List<String> uniqueFileNames = [];

    for (String originalName in fileNameList) {
      String name = originalName.trim().isEmpty ? 'file' : originalName;
      if (fileNameCount.containsKey(name)) {
        fileNameCount[name] = fileNameCount[name]! + 1;
        final extensionIndex = name.lastIndexOf('.');
        final base =
            extensionIndex != -1 ? name.substring(0, extensionIndex) : name;
        final ext = extensionIndex != -1 ? name.substring(extensionIndex) : '';
        name = '${base}_${fileNameCount[name]}$ext';
      } else {
        fileNameCount[name] = 1;
      }
      uniqueFileNames.add(name);
    }

    try {
      final result = await methodChannel
          .invokeMethod<List<dynamic>>('saveMultipleFiles', {
            'dataList': dataList,
            'fileNameList': uniqueFileNames,
            'mimeTypeList': mimeTypeList,
          });
      return result?.cast<String>() ?? [];
    } on PlatformException catch (e) {
      debugPrint('PlatformException: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error: $e');
      rethrow;
    }
  }
}
