import Foundation

public enum TranscriptCleaner {
    public static func clean(_ raw: String) -> String {
        raw
            .components(separatedBy: .newlines)
            .map { line in
                line.replacingOccurrences(
                    of: #"^\s*\[[0-9:.\-\>\s]+\]\s*"#,
                    with: "",
                    options: .regularExpression
                )
            }
            .joined(separator: " ")
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
