## 0.0.5

* **Breaking**: `saveMultipleFiles` now returns `Future<List<String>>` (saved paths) instead of `Future<void>`.
* **Breaking**: `saveFile` now returns `Future<String?>` (saved path) instead of `Future<void>`.
* Added Web platform support — triggers browser Blob download via `package:web`.
* Added Windows platform support — saves directly to the Downloads folder via `dart:io`.
* Added Linux platform support — saves directly to the Downloads folder via `dart:io`.
* Added macOS platform support — presents `NSSavePanel` so the user can choose the save location.
* Fixed: Android now handles `getPlatformVersion` and `getBatteryPercentage` (previously returned `notImplemented`).
* Fixed: iOS `batteryLevel` (Float 0.0–1.0) is now correctly converted to an integer percentage (0–100).
* Fixed: Removed 220+ lines of dead commented-out code from the iOS Swift implementation.
* Bumped version to 0.1.0 to reflect the breaking API change and new platform support.


## 0.0.3

* Added support android 9.

## 0.0.2

* Updated readme file.

## 0.0.1

* Initial release.