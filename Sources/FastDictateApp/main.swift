import AppKit
import FastDictateCore
import Foundation

final class AppDelegate: NSObject, NSApplicationDelegate, @unchecked Sendable {
    private var statusItem: NSStatusItem!
    private var menu: NSMenu!
    private var pasteAfterDictation = true
    private var isRunning = false

    @MainActor func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.title = "Dictate"
        statusItem.button?.toolTip = "Fast Dictate"

        menu = NSMenu()
        for preset in DictationPreset.all {
            let item = NSMenuItem(title: preset.title, action: #selector(dictatePreset(_:)), keyEquivalent: preset.keyEquivalent)
            item.representedObject = preset.duration
            menu.addItem(item)
        }
        menu.addItem(NSMenuItem.separator())

        let pasteItem = NSMenuItem(title: "Paste After Dictation", action: #selector(togglePaste), keyEquivalent: "")
        pasteItem.state = .on
        menu.addItem(pasteItem)

        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Fast Dictate", action: #selector(quit), keyEquivalent: "q"))

        for item in menu.items {
            item.target = self
        }

        statusItem.menu = menu
    }

    @MainActor @objc private func dictatePreset(_ sender: NSMenuItem) {
        guard let duration = sender.representedObject as? TimeInterval else { return }
        startDictation(duration: duration)
    }

    @MainActor @objc private func togglePaste(_ sender: NSMenuItem) {
        pasteAfterDictation.toggle()
        sender.state = pasteAfterDictation ? .on : .off
    }

    @MainActor @objc private func quit() {
        NSApp.terminate(nil)
    }

    @MainActor private func startDictation(duration: TimeInterval) {
        guard !isRunning else { return }
        isRunning = true
        setStatus("Rec")
        setMenuEnabled(false)

        let paste = pasteAfterDictation
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            do {
                let transcript = try Self.recordAndTranscribe(duration: duration, paste: paste)
                DispatchQueue.main.async { [weak self] in
                    self?.setStatus("Done")
                    self?.showResult(transcript)
                    self?.finishRun()
                }
            } catch {
                let errorMessage = "\(error)"
                DispatchQueue.main.async { [weak self] in
                    self?.setStatus("Error")
                    self?.showError(errorMessage)
                    self?.finishRun()
                }
            }
        }
    }

    private static func recordAndTranscribe(duration: TimeInterval, paste: Bool) throws -> String {
        let options = DictationOptions(duration: duration, paste: paste)
        let audioURL = FileManager.default.temporaryDirectory.appendingPathComponent("fast-dictate-app-\(UUID().uuidString).wav")

        try AudioRecorder().record(duration: options.duration, outputURL: audioURL)
        defer { try? FileManager.default.removeItem(at: audioURL) }

        let runner = WhisperRunner(executablePath: options.whisperPath, modelPath: options.modelPath)
        let transcript = try runner.transcribe(audioPath: audioURL.path)
        if transcript.isEmpty {
            throw AppError.noSpeechDetected
        }

        let pasteboard = PasteboardWriter()
        try pasteboard.copy(transcript)
        if options.paste {
            try pasteboard.pasteIntoActiveApp()
        }

        return transcript
    }

    @MainActor private func setStatus(_ title: String) {
        statusItem.button?.title = title
    }

    @MainActor private func setMenuEnabled(_ enabled: Bool) {
        menu.items.forEach { item in
            if item.action == #selector(dictatePreset(_:)) {
                item.isEnabled = enabled
            }
        }
    }

    @MainActor private func finishRun() {
        isRunning = false
        setMenuEnabled(true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            if self?.isRunning == false {
                self?.setStatus("Dictate")
            }
        }
    }

    @MainActor private func showResult(_ transcript: String) {
        let preview = transcript.count > 90 ? String(transcript.prefix(90)) + "..." : transcript
        let alert = NSAlert()
        alert.messageText = pasteAfterDictation ? "Dictation pasted" : "Dictation copied"
        alert.informativeText = preview
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    @MainActor private func showError(_ error: String) {
        let alert = NSAlert()
        alert.messageText = "Fast Dictate failed"
        alert.informativeText = error
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}

enum AppError: Error, CustomStringConvertible {
    case noSpeechDetected

    var description: String {
        switch self {
        case .noSpeechDetected:
            return "No speech detected. Try again with a longer duration or speak closer to the microphone."
        }
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
