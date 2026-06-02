import FastDictateCore
import Foundation

enum SelfTestFailure: Error, CustomStringConvertible {
    case failed(String)

    var description: String {
        switch self {
        case .failed(let message): message
        }
    }
}

func expect(_ condition: @autoclosure () -> Bool, _ message: String) throws {
    if !condition() {
        throw SelfTestFailure.failed(message)
    }
}

func testParsesExplicitOptions() throws {
    let options = try ArgumentParser.parse([
        "--duration", "12.5",
        "--model", "~/models/ggml-small.en.bin",
        "--whisper", "/opt/homebrew/bin/whisper-cli",
        "--paste",
        "--keep-audio",
        "--output-dir", "~/tmp"
    ], environment: [:])

    try expect(options.duration == 12.5, "duration should parse")
    try expect(options.modelPath?.hasSuffix("/models/ggml-small.en.bin") == true, "model path should expand tilde")
    try expect(options.whisperPath == "/opt/homebrew/bin/whisper-cli", "whisper path should parse")
    try expect(options.paste, "paste should parse")
    try expect(options.keepAudio, "keep audio should parse")
    try expect(options.outputDirectory?.hasSuffix("/tmp") == true, "output directory should expand tilde")
}

func testUsesEnvironmentDefaults() throws {
    let options = try ArgumentParser.parse([], environment: [
        "FAST_DICTATE_MODEL": "/models/model.bin",
        "FAST_DICTATE_WHISPER": "/bin/whisper-cli"
    ])

    try expect(options.duration == 8, "default duration should be 8")
    try expect(options.modelPath == "/models/model.bin", "model path should come from env")
    try expect(options.whisperPath == "/bin/whisper-cli", "whisper path should come from env")
    try expect(!options.paste, "paste should be off by default")
}

func testRejectsInvalidDuration() throws {
    do {
        _ = try ArgumentParser.parse(["--duration", "0"], environment: [:])
        throw SelfTestFailure.failed("invalid duration should throw")
    } catch let error as OptionParseError {
        try expect(error == .invalidDuration("0"), "invalid duration should identify bad value")
    }
}

func testCleansWhitespaceAndTimestamps() throws {
    let raw = """
    [00:00:00.000 --> 00:00:02.000]  hello world

    [00:00:02.000 --> 00:00:03.000]  from fast dictate
    """

    try expect(TranscriptCleaner.clean(raw) == "hello world from fast dictate", "transcript cleaner should strip timestamps")
}

func testMacAppFilesExist() throws {
    let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    let appMain = root.appendingPathComponent("Sources/FastDictateApp/main.swift").path
    let buildScript = root.appendingPathComponent("scripts/build-app.sh").path

    try expect(FileManager.default.fileExists(atPath: appMain), "menu bar app source should exist")
    try expect(FileManager.default.isExecutableFile(atPath: buildScript), "app bundle build script should exist and be executable")
}

func testLongVoiceNotePresetsExist() throws {
    let presets = DictationPreset.all
    try expect(presets.contains(.quick), "quick preset should exist")
    try expect(presets.contains(.note), "note preset should exist")
    try expect(presets.contains(.longNote), "long note preset should exist")
    try expect(presets.contains(.extendedNote), "extended note preset should exist")
    try expect(DictationPreset.longNote.duration == 300, "long note should record for 5 minutes")
    try expect(DictationPreset.extendedNote.duration == 900, "extended note should record for 15 minutes")
}

func testProductDocsAndFrontendExist() throws {
    let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    let prdURL = root.appendingPathComponent("docs/PRD.md")
    let frontendURL = root.appendingPathComponent("website/index.html")
    let iconURL = root.appendingPathComponent("Assets/FastDictateIcon.svg")

    try expect(FileManager.default.fileExists(atPath: prdURL.path), "PRD should exist at docs/PRD.md")
    try expect(FileManager.default.fileExists(atPath: frontendURL.path), "front end should exist at website/index.html")
    try expect(FileManager.default.fileExists(atPath: iconURL.path), "product icon should exist at Assets/FastDictateIcon.svg")

    let prd = try String(contentsOf: prdURL, encoding: .utf8)
    let frontend = try String(contentsOf: frontendURL, encoding: .utf8)
    let icon = try String(contentsOf: iconURL, encoding: .utf8)

    try expect(prd.contains("## Goals") && prd.contains("## Non-Goals") && prd.contains("## Success Metrics"), "PRD should include core product sections")
    try expect(frontend.contains("Fast Dictate") && frontend.contains("Assets/FastDictateIcon.svg"), "front end should name the product and reference the icon")
    try expect(icon.contains("<svg") && icon.contains("Fast Dictate"), "icon should be an accessible SVG")
}

let tests: [(String, () throws -> Void)] = [
    ("parses explicit options", testParsesExplicitOptions),
    ("uses environment defaults", testUsesEnvironmentDefaults),
    ("rejects invalid duration", testRejectsInvalidDuration),
    ("cleans whitespace and timestamps", testCleansWhitespaceAndTimestamps),
    ("mac app files exist", testMacAppFilesExist),
    ("long voice note presets exist", testLongVoiceNotePresetsExist),
    ("product docs and frontend exist", testProductDocsAndFrontendExist)
]

do {
    for (name, test) in tests {
        try test()
        print("PASS: \(name)")
    }
    print("All self-tests passed")
} catch {
    fputs("FAIL: \(error)\n", stderr)
    exit(1)
}
