import 'dart:js_interop';
import 'dart:typed_data';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart' as web;

import 'filesaverplus_platform_interface.dart';

/// Web implementation of [FileSaverPlusPlatform] using browser Blob downloads.
class FileSaverPlusWeb extends FileSaverPlusPlatform {
  static void registerWith(Registrar registrar) {
    FileSaverPlusPlatform.instance = FileSaverPlusWeb();
  }

  @override
  Future<String?> get platformVersion async => 'Web';

  @override
  Future<int?> get batteryPercentage async => null;

  @override
  Future<List<String>> saveMultipleFiles({
    required List<Uint8List> dataList,
    required List<String> fileNameList,
    required List<String> mimeTypeList,
  }) async {
    final results = <String>[];

    for (int i = 0; i < dataList.length; i++) {
      final blob = web.Blob(
        [dataList[i].toJS as JSAny].toJS,
        web.BlobPropertyBag(type: mimeTypeList[i]),
      );
      final url = web.URL.createObjectURL(blob);
      final anchor =
          web.document.createElement('a') as web.HTMLAnchorElement
            ..href = url
            ..download = fileNameList[i];

      web.document.body?.append(anchor);
      anchor.click();
      anchor.remove();
      web.URL.revokeObjectURL(url);

      results.add('download_triggered:${fileNameList[i]}');

      // Small delay between multiple downloads to avoid browser throttling.
      if (i < dataList.length - 1) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
    }

    return results;
  }
}
