import AVFoundation
import Foundation

public enum AudioRecorderError: Error, CustomStringConvertible {
    case microphonePermissionDenied
    case missingInputFormat

    public var description: String {
        switch self {
        case .microphonePermissionDenied:
            return "Microphone permission denied. Enable it in System Settings > Privacy & Security > Microphone."
        case .missingInputFormat:
            return "Could not read microphone input format."
        }
    }
}

public final class AudioRecorder {
    private let engine = AVAudioEngine()
    private var outputFile: AVAudioFile?

    public init() {}

    public func record(duration: TimeInterval, outputURL: URL) throws {
        try requestMicrophoneAccess()

        let input = engine.inputNode
        let format = input.outputFormat(forBus: 0)
        guard format.sampleRate > 0, format.channelCount > 0 else {
            throw AudioRecorderError.missingInputFormat
        }

        outputFile = try AVAudioFile(forWriting: outputURL, settings: format.settings)
        input.installTap(onBus: 0, bufferSize: 4096, format: format) { [weak self] buffer, _ in
            do {
                try self?.outputFile?.write(from: buffer)
            } catch {
                fputs("Audio write error: \(error)\n", stderr)
            }
        }

        try engine.start()
        Thread.sleep(forTimeInterval: duration)
        engine.stop()
        input.removeTap(onBus: 0)
        outputFile = nil
    }

    private func requestMicrophoneAccess() throws {
        let semaphore = DispatchSemaphore(value: 0)
        let state = MicrophoneAccessState()

        AVCaptureDevice.requestAccess(for: .audio) { granted in
            state.set(granted)
            semaphore.signal()
        }

        semaphore.wait()
        if !state.value {
            throw AudioRecorderError.microphonePermissionDenied
        }
    }
}

private final class MicrophoneAccessState: @unchecked Sendable {
    private let lock = NSLock()
    private var granted = false

    var value: Bool {
        lock.lock()
        defer { lock.unlock() }
        return granted
    }

    func set(_ value: Bool) {
        lock.lock()
        granted = value
        lock.unlock()
    }
}
