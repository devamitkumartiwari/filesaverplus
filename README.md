# FileSaverPlus

A Flutter plugin for saving files to device storage with full cross-platform support.

| Platform | Support | Mechanism |
|----------|---------|-----------|
| Android  | ✅ | MediaStore (API 29+) / direct file I/O (API 28) |
| iOS      | ✅ | UIActivityViewController share sheet |
| Web      | ✅ | Browser Blob download |
| Windows  | ✅ | dart:io → Downloads folder |
| Linux    | ✅ | dart:io → Downloads folder |
| macOS    | ✅ | NSSavePanel (user picks save location) |

---

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  filesaverplus: ^0.0.5
```

Then run:

```bash
flutter pub get
```

---

## Platform Setup

### Android

**Minimum SDK:** 28 (Android 9)

For Android 9 (API 28) only, add this permission to `AndroidManifest.xml`. Android 10+ does not require it.

```xml
<uses-permission
    android:name="android.permission.WRITE_EXTERNAL_STORAGE"
    android:maxSdkVersion="28" />
```

### iOS

**Minimum version:** iOS 13.0

No additional configuration needed. Files are shared via the system share sheet and the user selects the destination.

### Web, Windows, Linux, macOS

No additional setup required.

---

## Usage

### Save a single file

```dart
import 'dart:typed_data';
import 'package:filesaverplus/filesaverplus.dart';

final fileSaver = FileSaverPlus();

// Returns the saved file path (or null if unavailable on the platform).
final String? savedPath = await fileSaver.saveFile(
  Uint8List.fromList(utf8.encode('<h1>Hello</h1>')),
  'hello.html',
  'text/html',
);

print('Saved to: $savedPath');
```

### Save multiple files at once

```dart
final List<String> savedPaths = await fileSaver.saveMultipleFiles(
  dataList: [
    Uint8List.fromList(utf8.encode('Hello, world!')),
    Uint8List.fromList(utf8.encode('{"key": "value"}')),
  ],
  fileNameList: ['notes.txt', 'data.json'],
  mimeTypeList: ['text/plain', 'application/json'],
);

for (final path in savedPaths) {
  print('Saved: $path');
}
```

### Error handling

```dart
try {
  await fileSaver.saveFile(data, 'report.pdf', 'application/pdf');
} on ArgumentError catch (e) {
  // Invalid input (empty data, mismatched list lengths, etc.)
  print('Bad input: $e');
} on PlatformException catch (e) {
  switch (e.code) {
    case 'PERMISSION_DENIED':
      print('Storage permission denied (Android 9 only).');
      break;
    case 'ACTIVITY_NOT_ATTACHED':
      print('Activity not available (Android).');
      break;
    case 'VIEW_CONTROLLER_ERROR':
      print('Could not present share sheet (iOS).');
      break;
    case 'FILE_WRITE_ERROR':
      print('Failed to write file: ${e.message}');
      break;
    default:
      print('Platform error ${e.code}: ${e.message}');
  }
}
```

---

## API Reference

### `FileSaverPlus`

#### `saveFile(Uint8List data, String fileName, String mimeType) → Future<String?>`

Saves a single file. Returns the saved path, or `null` if the platform does not provide one (e.g. Web).

#### `saveMultipleFiles({required List<Uint8List> dataList, required List<String> fileNameList, required List<String> mimeTypeList}) → Future<List<String>>`

Saves multiple files in a single call. Returns a list of saved paths in the same order as the inputs.

Duplicate file names are automatically disambiguated by appending a counter (`file_2.txt`, `file_3.txt`, …).

#### `platformVersion → Future<String?>`

Returns a human-readable OS version string (e.g. `"Android 14"`, `"iOS 17.4"`).

#### `batteryPercentage → Future<int?>`

Returns the device battery level as an integer from 0 to 100. Returns `null` on platforms where this is unavailable (Web, Windows, Linux, macOS).

---

## Returned Paths by Platform

| Platform | Returned value |
|----------|---------------|
| Android (API 29+) | MediaStore content URI, e.g. `content://media/external/downloads/123` |
| Android (API 28) | Absolute file path, e.g. `/storage/emulated/0/Download/file.txt` |
| iOS | Temporary staging path (file is cleaned up after share sheet closes) |
| Web | `"download_triggered:<filename>"` |
| Windows / Linux | Absolute path in the Downloads folder |
| macOS | Absolute path chosen by the user via NSSavePanel; `"cancelled:<filename>"` if skipped |

---

## Error Codes

| Code | Platform | Meaning |
|------|----------|---------|
| `PERMISSION_DENIED` | Android | `WRITE_EXTERNAL_STORAGE` not granted (API 28 only) |
| `ACTIVITY_NOT_ATTACHED` | Android | Plugin called before Activity is ready |
| `INVALID_ARGUMENTS` | Android, iOS, macOS | Missing or mismatched arguments |
| `WRITE_FAILED` | Android | MediaStore insert returned null |
| `VIEW_CONTROLLER_ERROR` | iOS | Root view controller not found |
| `FILE_WRITE_ERROR` | iOS, macOS | Failed to write data to disk |
| `UNAVAILABLE` | Android, iOS | Battery level unavailable |

---

## Known Limitations

- **iOS**: The returned path is a temporary file that is deleted after the share sheet is dismissed. You cannot rely on it for subsequent reads.
- **Web**: The browser controls the download destination. There is no way to know where the file was saved.
- **macOS**: Each file opens a separate `NSSavePanel`. If the user cancels one panel, that file is skipped and its path is returned as `"cancelled:<filename>"`.
- **Android 9 (API 28)**: Requires `WRITE_EXTERNAL_STORAGE` permission and will prompt the user at runtime.

---

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Commit your changes
4. Push and open a Pull Request

Please run `flutter analyze` and `flutter test` before submitting.

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
