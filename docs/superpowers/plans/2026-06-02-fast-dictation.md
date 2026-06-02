# Fast Dictation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a local-only Mac dictation MVP that records microphone audio, transcribes it with `whisper.cpp`, copies the transcript, and optionally pastes it into the active app.

**Architecture:** A Swift Package contains a testable `FastDictateCore` library and a small `fast-dictate` executable. The CLI records fixed-duration audio with AVFoundation, calls a local `whisper.cpp` executable, cleans the transcript, writes it to the pasteboard, and optionally sends Command-V through AppleScript.

**Tech Stack:** Swift Package Manager, Swift 6, AVFoundation, AppKit pasteboard, `whisper.cpp` with Metal acceleration.

---

### Task 1: Project Scaffold

**Files:**
- Create: `Package.swift`
- Create: `Sources/FastDictateCore/DictationOptions.swift`
- Create: `Sources/FastDictate/main.swift`
- Create: `Tests/FastDictateTests/ArgumentParserTests.swift`

- [x] **Step 1: Write argument parser tests**

Create tests that verify duration, model path, whisper path, paste, retained audio, and environment defaults.

- [x] **Step 2: Implement parser**

Implement `DictationOptions`, `OptionParseError`, and `ArgumentParser.parse`.

- [x] **Step 3: Add CLI entrypoint**

Create `main.swift` with help handling and option parsing.

### Task 2: Transcript Cleaning

**Files:**
- Create: `Sources/FastDictateCore/TranscriptCleaner.swift`
- Create: `Tests/FastDictateTests/TranscriptCleanerTests.swift`

- [x] **Step 1: Write cleaning test**

Verify timestamped whisper output collapses to a single clean sentence.

- [x] **Step 2: Implement cleaner**

Strip whisper timestamps, collapse whitespace, and trim final transcript.

### Task 3: Local Engine Runner

**Files:**
- Create: `Sources/FastDictateCore/WhisperRunner.swift`

- [x] **Step 1: Add `WhisperRunner`**

Call `whisper.cpp` with `-m`, `-f`, `-otxt`, `-of`, `-nt`, and `-np`.

- [x] **Step 2: Add error cases**

Return explicit errors for missing model, failed subprocess, and missing transcript file.

### Task 4: Audio Capture and Paste

**Files:**
- Create: `Sources/FastDictateCore/AudioRecorder.swift`
- Create: `Sources/FastDictateCore/PasteboardWriter.swift`
- Modify: `Sources/FastDictate/main.swift`

- [x] **Step 1: Record microphone audio**

Use `AVAudioEngine` and `AVAudioFile` to write a temporary wav file.

- [x] **Step 2: Copy and optionally paste transcript**

Use `NSPasteboard` for copy and `/usr/bin/osascript` for Command-V paste.

### Task 5: Docs and Verification

**Files:**
- Create: `README.md`
- Create: `docs/superpowers/plans/2026-06-02-fast-dictation.md`

- [x] **Step 1: Document setup**

Explain how to build `whisper.cpp`, download `small.en`, configure environment variables, build the Swift package, and run dictation.

- [x] **Step 2: Run self-tests**

Run: `swift run fast-dictate-selftest`

Expected: all tests pass.

- [x] **Step 3: Build release binary**

Run: `swift build -c release`

Expected: `.build/release/fast-dictate` exists.
