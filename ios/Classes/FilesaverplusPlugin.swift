import Flutter
import UIKit

public class FilesaverplusPlugin: NSObject, FlutterPlugin {

    // MARK: - Registration

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "filesaverplus", binaryMessenger: registrar.messenger())
        let instance = FilesaverplusPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    // MARK: - Method Call Handling (Dispatcher)

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            handleGetPlatformVersion(result: result)

        case "getBatteryPercentage":
            handleGetBatteryPercentage(result: result)

        case "saveMultipleFiles":
            // Pass arguments directly to the specific handler
            handleSaveMultipleFiles(arguments: call.arguments, result: result)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Specific Method Handlers

    private func handleGetPlatformVersion(result: @escaping FlutterResult) {
        result("iOS " + UIDevice.current.systemVersion)
    }

    private func handleGetBatteryPercentage(result: @escaping FlutterResult) {
        // Ensure monitoring is enabled to read the level
        UIDevice.current.isBatteryMonitoringEnabled = true
        let batteryLevel = UIDevice.current.batteryLevel
        // Check if battery state allows reading the level
        if batteryLevel == -1.0 {
            // Level is unknown
             result(FlutterError(code: "UNAVAILABLE",
                                 message: "Battery level not available.",
                                 details: "Battery monitoring might be disabled or the device state is unknown."))
        } else {
            result(batteryLevel)
        }
        // Consider disabling monitoring again if needed
        // UIDevice.current.isBatteryMonitoringEnabled = false
    }

    private func handleSaveMultipleFiles(arguments: Any?, result: @escaping FlutterResult) {
        // Safely unwrap and cast arguments inside the specific handler
        guard let args = arguments as? [String: Any],
              let dataList = args["dataList"] as? [FlutterStandardTypedData],
              let fileNameList = args["fileNameList"] as? [String],
              let mimeTypeList = args["mimeTypeList"] as? [String] // Keep for API compatibility
        else {
            result(FlutterError(code: "INVALID_ARGUMENTS",
                                message: "Missing or invalid arguments. Expected: dataList ([Data]), fileNameList ([String]), mimeTypeList ([String])",
                                details: nil))
            return
        }

        // Validate that all lists have the same number of elements
        guard dataList.count == fileNameList.count, dataList.count == mimeTypeList.count else {
             result(FlutterError(code: "INVALID_ARGUMENTS",
                                 message: "Argument lists (dataList, fileNameList, mimeTypeList) must have the same number of elements.",
                                 details: "Received counts: dataList=\(dataList.count), fileNameList=\(fileNameList.count), mimeTypeList=\(mimeTypeList.count)"))
             return
         }

         // Ensure there's actually data to save
         guard !dataList.isEmpty else {
              print("Warning: saveMultipleFiles called with empty lists.")
              result(nil) // Indicate success (nothing to do)
             return
         }

        // Perform file saving and presentation asynchronously
         DispatchQueue.global(qos: .userInitiated).async {
             do {
                 // Note: mimeTypeList is still not used in createTemporaryFiles
                 let temporaryFileURLs = try self.createTemporaryFiles(dataList: dataList, fileNameList: fileNameList)
                 // Switch back to the main thread for UI presentation
                 DispatchQueue.main.async {
                     self.presentShareSheet(for: temporaryFileURLs, result: result)
                 }
             } catch {
                 // Handle errors from createTemporaryFiles
                 // Ensure result is called on the main thread
                 DispatchQueue.main.async {
                    if let savingError = error as? FileSavingError {
                         result(FlutterError(code: savingError.errorCode, message: savingError.localizedDescription, details: nil))
                    } else {
                         result(FlutterError(code: "FILE_WRITE_ERROR", message: error.localizedDescription, details: nil))
                    }
                 }
             }
         }
    }

    // MARK: - File Saving Logic & Helpers

    // Custom Error Enum remains the same
    enum FileSavingError: Error, LocalizedError {
        case cannotAccessViewController
        case fileWriteError(fileName: String, underlyingError: Error)
        case presentationError(message: String)

        var errorCode: String {
            switch self {
            case .cannotAccessViewController: return "VIEW_CONTROLLER_ERROR"
            case .fileWriteError: return "FILE_WRITE_ERROR"
            case .presentationError: return "PRESENTATION_ERROR"
            }
        }

        var errorDescription: String? {
             switch self {
             case .cannotAccessViewController:
                 return "Could not get the root view controller to present the share sheet."
             case .fileWriteError(let fileName, let underlyingError):
                 return "Failed to write temporary file '\(fileName)': \(underlyingError.localizedDescription)"
             case .presentationError(let message):
                 return message
             }
         }
    }

    // createTemporaryFiles remains the same
    private func createTemporaryFiles(dataList: [FlutterStandardTypedData], fileNameList: [String]) throws -> [URL] {
        let temporaryFolder = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        var temporaryFileURLs: [URL] = []

        temporaryFileURLs = try dataList.indices.map { index in
            let data = dataList[index].data
            let fileName = fileNameList[index]
            let temporaryFileURL = temporaryFolder.appendingPathComponent(fileName)
            do {
                try data.write(to: temporaryFileURL, options: .atomic)
                return temporaryFileURL
            } catch {
                throw FileSavingError.fileWriteError(fileName: fileName, underlyingError: error)
            }
        }
        return temporaryFileURLs
    }

    // presentShareSheet remains the same
    private func presentShareSheet(for temporaryFileURLs: [URL], result: @escaping FlutterResult) {
         guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
             guard let fallbackViewController = UIApplication.shared.keyWindow?.rootViewController else {
                 result(FlutterError(code: FileSavingError.cannotAccessViewController.errorCode,
                                     message: FileSavingError.cannotAccessViewController.localizedDescription,
                                     details: nil))
                 cleanupTemporaryFiles(urls: temporaryFileURLs)
                 return
             }
              self.presentActivityController(from: fallbackViewController, items: temporaryFileURLs, result: result)
              return
         }
        self.presentActivityController(from: rootViewController, items: temporaryFileURLs, result: result)
    }

    // presentActivityController remains the same
    private func presentActivityController(from viewController: UIViewController, items: [URL], result: @escaping FlutterResult) {
        let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityController.excludedActivityTypes = [
            .airDrop, .postToTwitter, .assignToContact, .postToFlickr, .postToWeibo, .markupAsPDF,
            .print, .copyToPasteboard, .addToReadingList, .openInIBooks
        ]

        activityController.completionWithItemsHandler = { activityType, completed, returnedItems, activityError in
            self.cleanupTemporaryFiles(urls: items)
            if let error = activityError {
                 print("UIActivityViewController error: \(error.localizedDescription)")
            }
        }

        if let popOver = activityController.popoverPresentationController {
            popOver.sourceView = viewController.view
            popOver.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
            popOver.permittedArrowDirections = []
        }

        viewController.present(activityController, animated: true) {
            // Presentation started successfully. Call result(nil).
            result(nil)
        }
    }

    // cleanupTemporaryFiles remains the same
    private func cleanupTemporaryFiles(urls: [URL]) {
        let fileManager = FileManager.default
        for url in urls {
            do {
                try fileManager.removeItem(at: url)
            } catch {
                print("Error cleaning up temporary file \(url.path): \(error.localizedDescription)")
            }
        }
    }
}



//import Flutter


//import UIKit
//
//public class FilesaverplusPlugin: NSObject, FlutterPlugin {
//
//    public static func register(with registrar: FlutterPluginRegistrar) {
//        let channel = FlutterMethodChannel(name: "filesaverplus", binaryMessenger: registrar.messenger())
//        let instance = FilesaverplusPlugin()
//        registrar.addMethodCallDelegate(instance, channel: channel)
//    }
//
//    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
//        switch call.method {
//        case "getPlatformVersion":
//            result("iOS " + UIDevice.current.systemVersion)
//
//        case "getBatteryPercentage":
//            // Ensure monitoring is enabled to read the level
//            UIDevice.current.isBatteryMonitoringEnabled = true
//            let batteryLevel = UIDevice.current.batteryLevel
//            // Check if battery state allows reading the level
//            if batteryLevel == -1.0 {
//                // Level is unknown (e.g., simulator, device state unknown, or monitoring couldn't be enabled)
//                 result(FlutterError(code: "UNAVAILABLE",
//                                     message: "Battery level not available.",
//                                     details: "Battery monitoring might be disabled or the device state is unknown."))
//            } else {
//                result(batteryLevel)
//            }
//            // Consider if you want to disable monitoring again if it was off before.
//            // Leaving it enabled might be expected by the caller.
//            // UIDevice.current.isBatteryMonitoringEnabled = false // Or restore previous state if needed
//
//        case "saveMultipleFiles":
//            // Safely unwrap and cast arguments
//            guard let args = call.arguments as? [String: Any],
//                  let dataList = args["dataList"] as? [FlutterStandardTypedData],
//                  let fileNameList = args["fileNameList"] as? [String],
//                  let mimeTypeList = args["mimeTypeList"] as? [String] // Keep for API compatibility, though unused locally
//            else {
//                result(FlutterError(code: "INVALID_ARGUMENTS",
//                                    message: "Missing or invalid arguments. Expected: dataList ([Data]), fileNameList ([String]), mimeTypeList ([String])",
//                                    details: nil))
//                return
//            }
//
//            // Validate that all lists have the same number of elements
//            guard dataList.count == fileNameList.count, dataList.count == mimeTypeList.count else {
//                 result(FlutterError(code: "INVALID_ARGUMENTS",
//                                     message: "Argument lists (dataList, fileNameList, mimeTypeList) must have the same number of elements.",
//                                     details: "Received counts: dataList=\(dataList.count), fileNameList=\(fileNameList.count), mimeTypeList=\(mimeTypeList.count)"))
//                 return
//             }
//
//             // Ensure there's actually data to save
//             guard !dataList.isEmpty else {
//                  // Technically valid input, but maybe worth returning early or specific success code?
//                  // Or handle as an error if saving zero files isn't desired.
//                  // Let's assume saving zero files is a no-op success for now.
//                  print("Warning: saveMultipleFiles called with empty lists.")
//                  result(nil) // Indicate success (nothing to do)
//                 // Or: result(FlutterError(code: "NO_FILES", message: "Cannot save zero files.", details: nil))
//                 return
//             }
//
//            // Perform file saving and presentation asynchronously
//             DispatchQueue.global(qos: .userInitiated).async {
//                 do {
//                     let temporaryFileURLs = try self.createTemporaryFiles(dataList: dataList, fileNameList: fileNameList)
//                     // Switch back to the main thread for UI presentation
//                     DispatchQueue.main.async {
//                         self.presentShareSheet(for: temporaryFileURLs, result: result)
//                     }
//                 } catch {
//                     // Handle errors from createTemporaryFiles (e.g., file writing error)
//                     // Ensure result is called on the main thread if coming from a background thread
//                     DispatchQueue.main.async {
//                        if let savingError = error as? FileSavingError {
//                             result(FlutterError(code: savingError.errorCode, message: savingError.localizedDescription, details: nil))
//                        } else {
//                             result(FlutterError(code: "FILE_WRITE_ERROR", message: error.localizedDescription, details: nil))
//                        }
//                     }
//                 }
//             }
//
//        default:
//            result(FlutterMethodNotImplemented)
//        }
//    }
//
//    // Custom Error Enum for clearer error handling
//    enum FileSavingError: Error, LocalizedError {
//        case cannotAccessViewController
//        case fileWriteError(fileName: String, underlyingError: Error)
//        case presentationError(message: String) // For errors during presentation setup
//
//        var errorCode: String {
//            switch self {
//            case .cannotAccessViewController: return "VIEW_CONTROLLER_ERROR"
//            case .fileWriteError: return "FILE_WRITE_ERROR"
//            case .presentationError: return "PRESENTATION_ERROR"
//            }
//        }
//
//        var errorDescription: String? {
//             switch self {
//             case .cannotAccessViewController:
//                 return "Could not get the root view controller to present the share sheet."
//             case .fileWriteError(let fileName, let underlyingError):
//                 return "Failed to write temporary file '\(fileName)': \(underlyingError.localizedDescription)"
//             case .presentationError(let message):
//                 return message
//             }
//         }
//    }
//
//    // Separated file creation logic
//    private func createTemporaryFiles(dataList: [FlutterStandardTypedData], fileNameList: [String]) throws -> [URL] {
//        let temporaryFolder = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
//        var temporaryFileURLs: [URL] = []
//        // Ensure we create a unique subfolder for this operation to avoid name collisions
//        // and make cleanup easier if needed, though NSTemporaryDirectory is generally sufficient.
//        // let operationSubFolder = temporaryFolder.appendingPathComponent(UUID().uuidString)
//        // try FileManager.default.createDirectory(at: operationSubFolder, withIntermediateDirectories: true, attributes: nil)
//
//        // Use map for concise iteration and error handling.
//        // The `throws` keyword allows errors to propagate up.
//        temporaryFileURLs = try dataList.indices.map { index in
//            let data = dataList[index].data
//            let fileName = fileNameList[index]
//            // Use the main temporary directory directly
//            let temporaryFileURL = temporaryFolder.appendingPathComponent(fileName)
//
//            do {
//                // Use atomic write for better safety against corruption if the app crashes mid-write
//                try data.write(to: temporaryFileURL, options: .atomic)
//                return temporaryFileURL
//            } catch {
//                // If one file fails, we might want to clean up previously created ones,
//                // but map doesn't easily allow this. A standard loop might be better for cleanup on partial failure.
//                // For now, rethrow the specific error.
//                throw FileSavingError.fileWriteError(fileName: fileName, underlyingError: error)
//            }
//        }
//        return temporaryFileURLs
//    }
//
//    // Separated share sheet presentation logic
//    private func presentShareSheet(for temporaryFileURLs: [URL], result: @escaping FlutterResult) {
//         // Get root view controller safely (must be on main thread)
//         guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//               let rootViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
//             // Fallback or error
//             guard let fallbackViewController = UIApplication.shared.keyWindow?.rootViewController else {
//                 result(FlutterError(code: FileSavingError.cannotAccessViewController.errorCode,
//                                     message: FileSavingError.cannotAccessViewController.localizedDescription,
//                                     details: nil))
//                 // Clean up files if VC fails
//                 cleanupTemporaryFiles(urls: temporaryFileURLs)
//                 return
//             }
//              self.presentActivityController(from: fallbackViewController, items: temporaryFileURLs, result: result)
//              return // Exit after attempting presentation with fallback
//         }
//
//        self.presentActivityController(from: rootViewController, items: temporaryFileURLs, result: result)
//    }
//
//    private func presentActivityController(from viewController: UIViewController, items: [URL], result: @escaping FlutterResult) {
//        let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
//
//        // Exclude specific activity types if desired
//        activityController.excludedActivityTypes = [
//            .airDrop, .postToTwitter, .assignToContact, .postToFlickr, .postToWeibo, .markupAsPDF,
//            .print, .copyToPasteboard, .addToReadingList, .openInIBooks // Add more as needed
//        ]
//
//        // Cleanup handler: This runs *after* the activity controller is dismissed or completed.
//        activityController.completionWithItemsHandler = { activityType, completed, returnedItems, activityError in
//            self.cleanupTemporaryFiles(urls: items)
//            if let error = activityError {
//                 // Log the error from the activity controller itself
//                 print("UIActivityViewController error: \(error.localizedDescription)")
//                 // Note: We cannot call 'result' again here as it was called upon initiating presentation.
//            }
//             // Log completion state if needed
//             // print("Share sheet completed: \(completed), Activity: \(activityType?.rawValue ?? "None")")
//        }
//
//        // Configure popover presentation for iPad
//        if let popOver = activityController.popoverPresentationController {
//            popOver.sourceView = viewController.view
//            // Present centered without an arrow
//            popOver.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
//            popOver.permittedArrowDirections = [] // Use empty array for clarity (no arrows)
//        }
//
//        // Present the view controller
//        viewController.present(activityController, animated: true) {
//            // Presentation started successfully. Call result(nil) here.
//            // This indicates to Flutter that the native operation (showing the share sheet) has begun.
//            result(nil)
//        }
//    }
//
//    // Helper function for cleaning up temporary files
//    private func cleanupTemporaryFiles(urls: [URL]) {
//        let fileManager = FileManager.default
//        for url in urls {
//            do {
//                try fileManager.removeItem(at: url)
//                // print("Cleaned up temporary file: \(url.lastPathComponent)") // Optional: for debugging
//            } catch {
//                print("Error cleaning up temporary file \(url.path): \(error.localizedDescription)")
//            }
//        }
//    }
//}