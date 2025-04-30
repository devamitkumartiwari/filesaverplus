# filesaverplus

# FileSaverPlus

FileSaverPlus is a mobile application that allows users to save and manage files efficiently on
their devices. The app supports various file formats and provides easy access to saved files.

## Install plugin

add this line into pubspec.yaml

```
filesaverplus: ^0.0.3
```

## Example uses

```
// import package.
import 'package:filesaverplus/filesaverplus.dart';

// for saving single file.
await FileSaverPlus().saveFile(Uint8List fileData, String fileName, String mimeType );


// for saving multiple files.
await FileSaverPlus().saveMultipleFiles(List<Uint8List> fileDataList, List<String> fileNameList, List<String> mimeTypeList)
```

## Features

- Save files from different sources.
- View and manage saved files.
- Organize files with custom labels or categories.
- Share files with others.

## Requirements

### iOS:

- iOS 13.0 or later.
- Flutter 3.29 or later.

### Android:

if your project set android target >= Android Q, you don't have to add any permission. Otherwise,
Add the following statement in AndroidManifest.xml:

```
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
        android:maxSdkVersion="28"/>
```

- Minimum SDK version 28 (Android 9 or later).
- Flutter 3.29 or later.

## Installation

### Clone the repository:

```bash
git clone https://github.com/devamitkumartiwari/filesaverplus.git


