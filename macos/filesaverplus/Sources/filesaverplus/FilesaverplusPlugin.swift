import Cocoa
import FlutterMacOS

public class FilesaverplusPlugin: NSObject, FlutterPlugin {

    // MARK: - Registration

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "filesaverplus",
            binaryMessenger: registrar.messenger
        )
        let instance = FilesaverplusPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    // MARK: - Method Call Dispatcher

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("macOS " + ProcessInfo.processInfo.operatingSystemVersionString)

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

        // NSSavePanel must run on the main thread.
        DispatchQueue.main.async {
            self.saveFilesSequentially(
                dataList: dataList,
                fileNameList: fileNameList,
                index: 0,
                savedPaths: [],
                result: result
            )
        }
    }

    // MARK: - Sequential NSSavePanel

    private func saveFilesSequentially(
        dataList: [FlutterStandardTypedData],
        fileNameList: [String],
        index: Int,
        savedPaths: [String],
        result: @escaping FlutterResult
    ) {
        guard index < dataList.count else {
            result(savedPaths)
            return
        }

        let panel = NSSavePanel()
        panel.nameFieldStringValue = fileNameList[index]
        panel.canCreateDirectories = true
        panel.prompt = "Save"

        panel.begin { response in
            guard response == .OK, let url = panel.url else {
                // User cancelled — skip this file and continue.
                var paths = savedPaths
                paths.append("cancelled:\(fileNameList[index])")
                self.saveFilesSequentially(
                    dataList: dataList,
                    fileNameList: fileNameList,
                    index: index + 1,
                    savedPaths: paths,
                    result: result
                )
                return
            }

            do {
                try dataList[index].data.write(to: url)
                var paths = savedPaths
                paths.append(url.path)
                self.saveFilesSequentially(
                    dataList: dataList,
                    fileNameList: fileNameList,
                    index: index + 1,
                    savedPaths: paths,
                    result: result
                )
            } catch {
                result(FlutterError(code: "FILE_WRITE_ERROR",
                                    message: "Failed to write '\(fileNameList[index])': \(error.localizedDescription)",
                                    details: nil))
            }
        }
    }
}
