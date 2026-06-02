# Fast Dictation Mac App Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Convert the local `fast-dictate` CLI into a usable macOS menu bar app.

**Architecture:** Add a SwiftPM executable target that runs as an AppKit status-bar app and reuses `FastDictateCore` for recording, transcription, clipboard copy, and paste. Add a bundling script that builds a `.app` with microphone usage metadata and installs it into `~/Applications`.

**Tech Stack:** Swift Package Manager, Swift 6, AppKit, AVFoundation, AppKit pasteboard, AppleScript paste, `whisper.cpp`.

---

### Task 1: Red Test for App Files

**Files:**
- Modify: `Tests/FastDictateTests/main.swift`

- [x] **Step 1: Add self-test**

Add `testMacAppFilesExist()` to check `Sources/FastDictateApp/main.swift` and executable `scripts/build-app.sh` exist.

- [x] **Step 2: Run self-test to verify failure**

Run: `swift run fast-dictate-selftest`

Expected: FAIL with `menu bar app source should exist`.

### Task 2: Menu Bar App Target

**Files:**
- Modify: `Package.swift`
- Create: `Sources/FastDictateApp/main.swift`

- [x] **Step 1: Add SwiftPM executable product**

Add product `fast-dictate-app` and target `FastDictateApp` depending on `FastDictateCore`.

- [x] **Step 2: Implement status bar app**

Create an AppKit app with menu items for `Dictate 8 Seconds`, `Dictate 15 Seconds`, `Paste After Dictation`, and quit.

### Task 3: App Bundle Script

**Files:**
- Create: `scripts/build-app.sh`

- [x] **Step 1: Build release app product**

Script runs `swift build -c release --product fast-dictate-app`.

- [x] **Step 2: Create `.app` bundle**

Script writes `Info.plist`, copies the executable to `Contents/MacOS/FastDictateApp`, and installs to `~/Applications/Fast Dictate.app`.

### Task 4: Verify

**Files:**
- Modify: `README.md`

- [x] **Step 1: Run self-tests**

Run: `swift run fast-dictate-selftest`

Expected: all self-tests pass.

- [x] **Step 2: Build and install app**

Run: `scripts/build-app.sh`

Expected: `/Users/SGK/Applications/Fast Dictate.app` exists.
