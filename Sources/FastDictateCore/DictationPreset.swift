import Foundation

public struct DictationPreset: Equatable, Sendable {
    public let title: String
    public let duration: TimeInterval
    public let keyEquivalent: String

    public init(title: String, duration: TimeInterval, keyEquivalent: String = "") {
        self.title = title
        self.duration = duration
        self.keyEquivalent = keyEquivalent
    }

    public static let quick = DictationPreset(title: "Dictate 8 Seconds", duration: 8, keyEquivalent: "d")
    public static let note = DictationPreset(title: "Voice Note 1 Minute", duration: 60)
    public static let longNote = DictationPreset(title: "Long Voice Note 5 Minutes", duration: 300)
    public static let extendedNote = DictationPreset(title: "Extended Voice Note 15 Minutes", duration: 900)

    public static let all: [DictationPreset] = [
        .quick,
        .note,
        .longNote,
        .extendedNote
    ]
}
