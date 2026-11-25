import 'dart:convert';
import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';

/// A ready-made file the example can save.
class SampleFile {
  const SampleFile({
    required this.label,
    required this.fileName,
    required this.mimeType,
    required this.icon,
    required this.build,
  });

  final String label;
  final String fileName;
  final String mimeType;
  final IconData icon;

  /// Builds the bytes at save time, so timestamps are fresh.
  final Uint8List Function() build;

  String get extension => fileName.split('.').last.toUpperCase();
}

Uint8List _utf8(String s) => Uint8List.fromList(utf8.encode(s));

/// 64×64 PNG of the FileSaverPlus icon (203 bytes), to show binary saves.
final Uint8List _iconPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAEAAAABAAgMAAADXB5lNAAAACVBMVEX/////swAAiXvgZPvjAAAA'
  'fUlEQVR42u3TPQrAIAwGUOkd45Aj5D7Zu0Swp2wiTRqEduoiNILgQz5/0HJMVdYHhh9uaAYtARtw'
  'AiAFoIAOyKBdgEBl0C7NANaGKWMUpVUGpFXExjVBN8C89YhwYI9wEI9w6B4Rx/eI5wuSOkHH+UnR'
  '2xvby1Xbh7DonzsBE1NtXgCx5HwAAAAASUVORK5CYII=',
);

final List<SampleFile> sampleFiles = [
  SampleFile(
    label: 'Text',
    fileName: 'hello.txt',
    mimeType: 'text/plain',
    icon: Icons.text_snippet_outlined,
    build: () => _utf8(
      'Hello from FileSaverPlus!\n\nSaved at ${DateTime.now().toIso8601String()}\n',
    ),
  ),
  SampleFile(
    label: 'HTML',
    fileName: 'demo.html',
    mimeType: 'text/html',
    icon: Icons.html_outlined,
    build: () => _utf8(
      '<!DOCTYPE html>\n<html><head><title>FileSaverPlus</title></head>\n'
      '<body><h1>Hello, FileSaverPlus!</h1>'
      '<p>Saved without any permission.</p></body></html>\n',
    ),
  ),
  SampleFile(
    label: 'JSON',
    fileName: 'plugin_info.json',
    mimeType: 'application/json',
    icon: Icons.data_object_outlined,
    build: () => _utf8(
      const JsonEncoder.withIndent('  ').convert({
        'plugin': 'filesaverplus',
        'version': '1.1.0',
        'platforms': ['android', 'ios', 'macos', 'web', 'windows', 'linux'],
        'permissions': <String>[],
        'savedAt': DateTime.now().toIso8601String(),
      }),
    ),
  ),
  SampleFile(
    label: 'CSV',
    fileName: 'platforms.csv',
    mimeType: 'text/csv',
    icon: Icons.table_chart_outlined,
    build: () => _utf8(
      'platform,minimum,saves to\n'
      'Android,7.0,Downloads\n'
      'iOS,16.0,Share sheet\n'
      'macOS,12.0,Save panel\n',
    ),
  ),
  SampleFile(
    label: 'PNG image',
    fileName: 'icon.png',
    mimeType: 'image/png',
    icon: Icons.image_outlined,
    build: () => _iconPng,
  ),
];
