import AppKit
import Foundation

public enum PasteboardWriterError: Error, CustomStringConvertible {
    case failedToCopy
    case failedToPaste(String)

    public var description: String {
        switch self {
        case .failedToCopy:
            return "Failed to copy transcript to pasteboard"
        case .failedToPaste(let error):
            return "Failed to paste transcript: \(error)"
        }
    }
}

public struct PasteboardWriter {
    public init() {}

    public func copy(_ text: String) throws {
        NSPasteboard.general.clearContents()
        guard NSPasteboard.general.setString(text, forType: .string) else {
            throw PasteboardWriterError.failedToCopy
        }
    }

    public func pasteIntoActiveApp() throws {
        let script = "tell application \"System Events\" to keystroke \"v\" using command down"
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        process.arguments = ["-e", script]

        let stderr = Pipe()
        process.standardError = stderr

        try process.run()
        process.waitUntilExit()

        if process.terminationStatus != 0 {
            let error = String(data: stderr.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
            throw PasteboardWriterError.failedToPaste(error)
        }
    }
}
