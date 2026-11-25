import Flutter
import UIKit

public class FilesaverplusPlugin: NSObject, FlutterPlugin {

    // MARK: - Registration

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "filesaverplus", binaryMessenger: registrar.messenger())
        let instance = FilesaverplusPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    // MARK: - Method Call Dispatcher

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)

        case "getBatteryPercentage":
            UIDevice.current.isBatteryMonitoringEnabled = true
            let level = UIDevice.current.batteryLevel
            if level < 0 {
                result(FlutterError(code: "UNAVAILABLE",
                                    message: "Battery level not available.",
                                    details: nil))
            } else {
                // batteryLevel is 0.0–1.0; convert to 0–100 integer
                result(Int(level * 100))
            }

        case "saveMultipleFiles":
            handleSaveMultipleFiles(arguments: call.arguments, result: result)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Save Multiple Files

    private func handleSaveMultipleFiles(arguments: Any?, result: @escaping FlutterResult) {
        guard let args = arguments as? [String: Any],
              let dataList = args["dataList"] as? [FlutterStandardTypedData],
              let fileNameList = args["fileNameList"] as? [String],
              let mimeTypeList = args["mimeTypeList"] as? [String]
        else {
            result(FlutterError(code: "INVALID_ARGUMENTS",
                                message: "Expected dataList, fileNameList, mimeTypeList.",
                                details: nil))
            return
        }

        guard dataList.count == fileNameList.count, dataList.count == mimeTypeList.count else {
            result(FlutterError(code: "INVALID_ARGUMENTS",
                                message: "All argument lists must have the same number of elements.",
                                details: nil))
            return
        }

        guard !dataList.isEmpty else {
            result([String]())
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let tempURLs = try self.createTemporaryFiles(dataList: dataList, fileNameList: fileNameList)
                DispatchQueue.main.async {
                    self.presentShareSheet(for: tempURLs, result: result)
                }
            } catch let error as FileSavingError {
                DispatchQueue.main.async {
                    result(FlutterError(code: error.errorCode,
                                       message: error.localizedDescription,
                                       details: nil))
                }
            } catch {
                DispatchQueue.main.async {
                    result(FlutterError(code: "FILE_WRITE_ERROR",
                                       message: error.localizedDescription,
                                       details: nil))
                }
            }
        }
    }

    // MARK: - File Helpers

    private enum FileSavingError: Error, LocalizedError {
        case cannotAccessViewController
        case fileWriteError(fileName: String, underlyingError: Error)

        var errorCode: String {
            switch self {
            case .cannotAccessViewController: return "VIEW_CONTROLLER_ERROR"
            case .fileWriteError: return "FILE_WRITE_ERROR"
            }
        }

        var errorDescription: String? {
            switch self {
            case .cannotAccessViewController:
                return "Could not get the root view controller to present the share sheet."
            case .fileWriteError(let fileName, let underlyingError):
                return "Failed to write temporary file '\(fileName)': \(underlyingError.localizedDescription)"
            }
        }
    }

    /// Writes every file into a fresh, per-call folder inside the temporary
    /// directory, so repeated or concurrent calls never overwrite each other.
    private func createTemporaryFiles(dataList: [FlutterStandardTypedData],
                                      fileNameList: [String]) throws -> [URL] {
        let folder = FileManager.default.temporaryDirectory
            .appendingPathComponent("filesaverplus", isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)

        var used = Set<String>()
        return try dataList.indices.map { i in
            let name = Self.uniqueName(Self.sanitize(fileNameList[i]), used: &used)
            let url = folder.appendingPathComponent(name, isDirectory: false)
            do {
                try dataList[i].data.write(to: url, options: .atomic)
                return url
            } catch {
                try? FileManager.default.removeItem(at: folder)
                throw FileSavingError.fileWriteError(fileName: name, underlyingError: error)
            }
        }
    }

    /// Replaces characters that are illegal in file names; never returns an empty name.
    static func sanitize(_ name: String) -> String {
        let illegal = CharacterSet(charactersIn: "/\\:*?\"<>|").union(.controlCharacters)
        let cleaned = name.unicodeScalars
            .map { illegal.contains($0) ? "_" : String($0) }
            .joined()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "."))
        return cleaned.isEmpty ? "file" : cleaned
    }

    private static func uniqueName(_ name: String, used: inout Set<String>) -> String {
        var candidate = name
        var n = 1
        let ext = (name as NSString).pathExtension
        let base = (name as NSString).deletingPathExtension
        while used.contains(candidate.lowercased()) {
            n += 1
            candidate = ext.isEmpty ? "\(base)_\(n)" : "\(base)_\(n).\(ext)"
        }
        used.insert(candidate.lowercased())
        return candidate
    }

    private func presentShareSheet(for urls: [URL], result: @escaping FlutterResult) {
        guard let rootVC = topViewController() else {
            cleanupTemporaryFiles(urls: urls)
            result(FlutterError(code: FileSavingError.cannotAccessViewController.errorCode,
                                message: FileSavingError.cannotAccessViewController.localizedDescription,
                                details: nil))
            return
        }

        let activityVC = UIActivityViewController(activityItems: urls, applicationActivities: nil)
        activityVC.excludedActivityTypes = [
            .airDrop, .postToTwitter, .assignToContact, .postToFlickr,
            .postToWeibo, .markupAsPDF, .print, .copyToPasteboard,
            .addToReadingList, .openInIBooks,
        ]

        activityVC.completionWithItemsHandler = { _, _, _, activityError in
            self.cleanupTemporaryFiles(urls: urls)
            if let err = activityError {
                print("UIActivityViewController error: \(err.localizedDescription)")
            }
        }

        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = rootVC.view
            popover.sourceRect = CGRect(x: rootVC.view.bounds.midX,
                                        y: rootVC.view.bounds.midY,
                                        width: 0, height: 0)
            popover.permittedArrowDirections = []
        }

        rootVC.present(activityVC, animated: true) {
            // Return temp file paths so callers know which files were staged.
            result(urls.map { $0.path })
        }
    }

    /// The view controller to present from: the top of the presentation stack
    /// in the foreground-active scene. Presenting from the root view controller
    /// silently fails while another modal (sheet, dialog, picker) is showing.
    private func topViewController() -> UIViewController? {
        let windowScenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }

        // Prefer the foreground-active scene so this behaves correctly when an
        // app has multiple concurrent scenes (iPad Stage Manager, Slide Over,
        // multi-window). Fall back to any other connected scene if none is
        // currently active (e.g. called during a scene transition).
        let scene = windowScenes.first { $0.activationState == .foregroundActive } ?? windowScenes.first
        guard let scene else { return nil }

        let window = scene.windows.first(where: { $0.isKeyWindow }) ?? scene.windows.first
        var top = window?.rootViewController
        while let presented = top?.presentedViewController, !presented.isBeingDismissed {
            top = presented
        }
        return top
    }

    /// Removes the per-call staging folder (and with it every staged file).
    private func cleanupTemporaryFiles(urls: [URL]) {
        guard let folder = urls.first?.deletingLastPathComponent() else { return }
        try? FileManager.default.removeItem(at: folder)
    }
}
