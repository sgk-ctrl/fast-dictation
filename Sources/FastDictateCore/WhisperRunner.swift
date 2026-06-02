import Foundation

public enum WhisperRunnerError: Error, CustomStringConvertible {
    case missingModel
    case failed(status: Int32, stderr: String)
    case missingTranscriptFile(String)

    public var description: String {
        switch self {
        case .missingModel:
            return "Missing model path. Pass --model or set FAST_DICTATE_MODEL."
        case .failed(let status, let stderr):
            return "whisper.cpp failed with status \(status): \(stderr)"
        case .missingTranscriptFile(let path):
            return "whisper.cpp did not create transcript file: \(path)"
        }
    }
}

public struct WhisperRunner {
    public var executablePath: String
    public var modelPath: String?

    public init(executablePath: String, modelPath: String?) {
        self.executablePath = executablePath
        self.modelPath = modelPath
    }

    public func transcribe(audioPath: String) throws -> String {
        guard let modelPath, !modelPath.isEmpty else {
            throw WhisperRunnerError.missingModel
        }

        let outputBase = FileManager.default.temporaryDirectory
            .appendingPathComponent("fast-dictate-\(UUID().uuidString)")
            .path
        let transcriptPath = outputBase + ".txt"

        let process = Process()
        let whisperArguments = [
            "-m", modelPath,
            "-f", audioPath,
            "-otxt",
            "-of", outputBase,
            "-nt",
            "-np"
        ]

        if executablePath.contains("/") {
            process.executableURL = URL(fileURLWithPath: NSString(string: executablePath).expandingTildeInPath)
            process.arguments = whisperArguments
        } else {
            process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
            process.arguments = [executablePath] + whisperArguments
        }

        let stderr = Pipe()
        process.standardError = stderr
        process.standardOutput = Pipe()

        try process.run()
        process.waitUntilExit()

        if process.terminationStatus != 0 {
            let stderrText = String(data: stderr.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
            throw WhisperRunnerError.failed(status: process.terminationStatus, stderr: stderrText)
        }

        guard FileManager.default.fileExists(atPath: transcriptPath) else {
            throw WhisperRunnerError.missingTranscriptFile(transcriptPath)
        }

        let raw = try String(contentsOfFile: transcriptPath, encoding: .utf8)
        try? FileManager.default.removeItem(atPath: transcriptPath)
        return TranscriptCleaner.clean(raw)
    }

}
