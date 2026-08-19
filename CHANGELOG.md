## 0.0.6

* Raised the minimum supported Flutter version to 3.24.0 (Dart 3.13.0) — the version Swift Package Manager plugin support was introduced.
* Android: bumped `compileSdk`/`targetSdk` to 37 (Android 17) and AGP to 9.3.1 (required to build against API 37). Stayed on the classic `kotlin-android` Gradle plugin rather than Flutter's new built-in Kotlin support — as of Flutter 3.47.0, built-in Kotlin fails a plain `flutter build`/`flutter run` for consumers of this plugin; will revisit once that's fixed upstream.
* iOS and macOS: added Swift Package Manager support alongside the existing CocoaPods podspecs, ahead of CocoaPods going read-only on pub.dev in December 2026. Verified via `pod lib lint` and full example builds (both CocoaPods and SwiftPM paths) on Xcode 26.6 (Xcode 27 is still in beta as of this release).
* iOS: fixed `saveMultipleFiles`/share-sheet presentation to correctly pick the foreground-active `UIWindowScene` and stopped falling back to the deprecated `UIApplication.shared.keyWindow`, so it behaves correctly in multi-scene contexts (iPad Stage Manager, Slide Over, multi-window).
* Bumped `flutter_lints` to ^6.0.0, and the floors on `plugin_platform_interface`, `path_provider`, and `web` to their current latest releases.
* macOS: documented the `com.apple.security.files.user-selected.read-write` entitlement sandboxed apps need for `NSSavePanel` writes to actually succeed — previously undocumented, and saves would silently fail under App Sandbox without it.

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