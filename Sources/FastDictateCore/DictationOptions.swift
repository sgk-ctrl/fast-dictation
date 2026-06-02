import Foundation

public struct DictationOptions: Equatable {
    public var duration: TimeInterval
    public var modelPath: String?
    public var whisperPath: String
    public var paste: Bool
    public var keepAudio: Bool
    public var outputDirectory: String?

    public init(
        duration: TimeInterval = 8,
        modelPath: String? = DictationDefaults.modelPath(environment: ProcessInfo.processInfo.environment),
        whisperPath: String = DictationDefaults.whisperPath(environment: ProcessInfo.processInfo.environment),
        paste: Bool = false,
        keepAudio: Bool = false,
        outputDirectory: String? = nil
    ) {
        self.duration = duration
        self.modelPath = modelPath
        self.whisperPath = whisperPath
        self.paste = paste
        self.keepAudio = keepAudio
        self.outputDirectory = outputDirectory
    }
}

public enum DictationDefaults {
    public static func modelPath(environment: [String: String] = ProcessInfo.processInfo.environment) -> String? {
        if let model = environment["FAST_DICTATE_MODEL"], !model.isEmpty {
            return NSString(string: model).expandingTildeInPath
        }

        let localModel = NSString(string: "~/Code/whisper.cpp/models/ggml-small.en.bin").expandingTildeInPath
        if FileManager.default.fileExists(atPath: localModel) {
            return localModel
        }

        return nil
    }

    public static func whisperPath(environment: [String: String] = ProcessInfo.processInfo.environment) -> String {
        if let whisper = environment["FAST_DICTATE_WHISPER"], !whisper.isEmpty {
            return NSString(string: whisper).expandingTildeInPath
        }

        let localWhisper = NSString(string: "~/Code/whisper.cpp/build/bin/whisper-cli").expandingTildeInPath
        if FileManager.default.isExecutableFile(atPath: localWhisper) {
            return localWhisper
        }

        return "whisper-cli"
    }
}

public enum OptionParseError: Error, Equatable, CustomStringConvertible {
    case missingValue(String)
    case invalidDuration(String)
    case unknownArgument(String)

    public var description: String {
        switch self {
        case .missingValue(let flag):
            return "Missing value for \(flag)"
        case .invalidDuration(let value):
            return "Invalid duration: \(value)"
        case .unknownArgument(let value):
            return "Unknown argument: \(value)"
        }
    }
}

public struct ArgumentParser {
    public static func parse(_ arguments: [String], environment: [String: String] = ProcessInfo.processInfo.environment) throws -> DictationOptions {
        var options = DictationOptions(
            modelPath: DictationDefaults.modelPath(environment: environment),
            whisperPath: DictationDefaults.whisperPath(environment: environment)
        )
        var index = 0

        while index < arguments.count {
            let argument = arguments[index]
            switch argument {
            case "--duration", "-d":
                index += 1
                guard index < arguments.count else { throw OptionParseError.missingValue(argument) }
                guard let duration = TimeInterval(arguments[index]), duration > 0 else {
                    throw OptionParseError.invalidDuration(arguments[index])
                }
                options.duration = duration
            case "--model", "-m":
                index += 1
                guard index < arguments.count else { throw OptionParseError.missingValue(argument) }
                options.modelPath = NSString(string: arguments[index]).expandingTildeInPath
            case "--whisper":
                index += 1
                guard index < arguments.count else { throw OptionParseError.missingValue(argument) }
                options.whisperPath = NSString(string: arguments[index]).expandingTildeInPath
            case "--paste":
                options.paste = true
            case "--copy-only":
                options.paste = false
            case "--keep-audio":
                options.keepAudio = true
            case "--output-dir":
                index += 1
                guard index < arguments.count else { throw OptionParseError.missingValue(argument) }
                options.outputDirectory = NSString(string: arguments[index]).expandingTildeInPath
            case "--help", "-h":
                throw OptionParseError.unknownArgument(argument)
            default:
                throw OptionParseError.unknownArgument(argument)
            }
            index += 1
        }

        return options
    }
}

public let usageText = """
Usage: fast-dictate [options]

Records microphone audio, transcribes it locally with whisper.cpp, copies the transcript, and optionally pastes it into the active app.

Options:
  -d, --duration SECONDS     Recording duration. Default: 8
  -m, --model PATH           whisper.cpp ggml model path. Can also use FAST_DICTATE_MODEL
      --whisper PATH         whisper.cpp executable. Default: FAST_DICTATE_WHISPER or whisper-cli
      --paste                Paste transcript into the active app after copying
      --copy-only            Copy transcript without pasting. Default
      --keep-audio           Keep recorded wav file
      --output-dir PATH      Directory for retained audio files
  -h, --help                 Show this help

Example:
  fast-dictate --duration 10 --model ~/models/ggml-small.en.bin --paste
"""
