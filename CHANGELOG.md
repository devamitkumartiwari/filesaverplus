## 1.1.0

* **Breaking (iOS/macOS): CocoaPods support removed.** The plugin now ships only as a Swift
  package, so apps need Swift Package Manager turned on (`flutter config
  --enable-swift-package-manager`). Other plugins in your app can still use CocoaPods.
* **Breaking (Android 7–9): files are saved to the app-specific Downloads folder**
  (`Android/data/<package>/files/Download`) instead of the public one. Writing to the public
  folder on those versions needs `WRITE_EXTERNAL_STORAGE`, and the plugin no longer asks for it.
  Android 10+ still saves to the public Downloads folder.
* **No permissions on any platform.** The plugin no longer declares, checks or requests
  `WRITE_EXTERNAL_STORAGE` and no longer shows a runtime permission dialog. `ActivityAware` and
  the undeclared `androidx.core` usage are gone; the Android code now depends only on the
  platform SDK.
* **Android minimum lowered from API 28 to API 24 (Android 7.0)**, matching Flutter's default
  `minSdkVersion`.
* **Flutter 3.50 baseline:** `flutter: '>=3.50.0'`, Dart `^3.14.0`.
  * Android: AGP 9.3.1, Kotlin 2.4.20, Gradle 9.5.0, `compileSdk`/`targetSdk` 37.
  * The plugin now applies the Kotlin Gradle Plugin only when AGP 9's built-in Kotlin is off.
    Previously, an AGP 9 app with `android.builtInKotlin=false` (Flutter's template default)
    could end up with nothing compiling the plugin's Kotlin sources.
  * macOS minimum raised from 10.14 to 12.0; iOS stays at 16.0.
* Android performance: files are written on a background thread instead of the UI thread, so
  large saves no longer cause jank.
* Fixes:
  * Android: a failed write no longer leaves a half-written, pending MediaStore entry behind.
  * Android: errors now include the file that failed (`WRITE_FAILED`), and `details` carries
    the paths that were saved before the failure.
  * iOS: files are staged in a unique per-call folder, so two saves with the same file name no
    longer overwrite each other. The whole folder is removed when the share sheet closes.
  * iOS: the share sheet is presented from the top-most view controller, so it now appears
    when another modal (sheet, dialog, picker) is already on screen.
  * Web: the object URL is revoked after a delay, so Safari and Firefox no longer cancel the
    download.
  * Windows/Linux: existing files are no longer overwritten (`name (1).ext`), and a missing
    Downloads folder is created.
  * Input validation, file-name sanitizing (`/ \ : * ? " < > |` and control characters) and
    duplicate renaming (`data.txt`, `data_2.txt`) now run on every platform, not only Android
    and iOS.
  * `saveMultipleFiles` always reports `ArgumentError` through the returned `Future`.
* macOS: added a privacy manifest (`PrivacyInfo.xcprivacy`), matching iOS.
* Example app:
  * Redesigned with Material 3 (`package:material_ui`) and light and dark themes. It now
    has several pages, like local_biometric's example:
    * Home: platform status, where files go, and links to each feature.
    * Single file: text, HTML, JSON, CSV or a PNG image, with a preview.
    * Multiple files: pick files and optionally save each one twice to show duplicate renaming.
    * Custom file: type your own name, MIME type and content to see sanitizing and errors.
    * History: every save from the session.
  * Swift Package Manager only (no Podfile).
  * New lightweight icon, including an Android adaptive and themed icon. Icons shrink from
    264 KB to about 30 KB. The app is now named "FileSaverPlus".
  * Fixed the widget test, which checked for text that didn't exist.
* No changes to the public Dart API.

## 1.0.0

* Android: downgraded Gradle `9.7.0` → `9.3.1`, AGP `9.3.1` → `9.1.0`, and Kotlin `2.3.21` → `2.4.0` — AGP 9.3.1 requires Gradle ≥9.5.0, so the Gradle downgrade also required dropping AGP to a version actually compatible with it.
* Android: `kotlin-android` is now applied conditionally based on AGP major version instead of unconditionally via `id("kotlin-android")` — the unconditional form can silently fail to compile Kotlin sources under some AGP/Gradle declarative `plugins{}` configurations.
* Android: removed a stray, non-functional `android.minSdkVersion=29` line from `gradle-wrapper.properties`.
* Adopted stricter analyzer rules: `strict-casts`, `strict-raw-types`, `cancel_subscriptions`, `close_sinks`, `unawaited_futures`.

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