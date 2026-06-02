import FastDictateCore
import Foundation

func fail(_ message: String, code: Int32 = 1) -> Never {
    fputs("\(message)\n", stderr)
    exit(code)
}

let arguments = Array(CommandLine.arguments.dropFirst())
if arguments.contains("--help") || arguments.contains("-h") {
    print(usageText)
    exit(0)
}

let options: DictationOptions
do {
    options = try ArgumentParser.parse(arguments)
} catch {
    fail("\(error)\n\n\(usageText)")
}

let outputDirectory = options.outputDirectory.map(URL.init(fileURLWithPath:)) ?? FileManager.default.temporaryDirectory
let audioURL = outputDirectory.appendingPathComponent("fast-dictate-\(UUID().uuidString).wav")

do {
    print("Recording for \(String(format: "%.1f", options.duration))s...")
    try AudioRecorder().record(duration: options.duration, outputURL: audioURL)

    print("Transcribing locally...")
    let runner = WhisperRunner(executablePath: options.whisperPath, modelPath: options.modelPath)
    let transcript = try runner.transcribe(audioPath: audioURL.path)

    if !options.keepAudio {
        try? FileManager.default.removeItem(at: audioURL)
    } else {
        print("Audio retained at \(audioURL.path)")
    }

    if transcript.isEmpty {
        fail("No speech detected.")
    }

    let pasteboard = PasteboardWriter()
    try pasteboard.copy(transcript)
    if options.paste {
        try pasteboard.pasteIntoActiveApp()
    }

    print(transcript)
} catch {
    fail("\(error)")
}
