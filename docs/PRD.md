# Fast Dictate PRD

## Summary

Fast Dictate is a local-first macOS dictation app that turns spoken thoughts into text in the active app. It targets writers, builders, and Mac power users who want fast private dictation for short commands and long voice notes without a cloud service.

## Problem

People often form ideas faster by speaking than by typing, but most dictation tools make a bad trade: they are either cloud-based, too slow to feel like a utility, or built for meetings instead of personal thought capture. The user wants to press one control, speak for seconds or minutes, and get clean text inserted where they were already working.

## Target Users

### Primary User: Solo Builder

The solo builder writes prompts, issues, plans, emails, and notes all day. They want to capture rough thinking without opening a separate recorder, uploading audio, or cleaning up a transcript manually.

### Secondary User: Privacy-Sensitive Note Taker

This user records personal thoughts, business ideas, or sensitive notes. They will not adopt a tool unless the core transcription path stays local.

### Secondary User: Mac Automation User

This user already lives in menu bar utilities, Terminal, Raycast, and local tools. They value a transparent implementation, CLI fallback, and GitHub-installable source.

## Goals

- Provide a local macOS dictation workflow that requires no cloud API.
- Let users dictate into any app through clipboard copy and optional paste.
- Support short dictation and long voice notes from the same menu bar app.
- Keep the engine swappable so `whisper.cpp`, MLX Whisper, or future local models can replace each other.
- Publish a clean open-source repository with setup docs, product docs, and a presentable front end.

## Non-Goals

- Real-time meeting transcription with speaker labels.
- Cloud transcription or account-based sync.
- Team analytics, meeting summaries, or collaboration features.
- A full transcript editor in the first product version.
- Mobile support.

## Current Product State

Fast Dictate currently ships as a Swift Package with:

- `fast-dictate`: a CLI that records fixed-duration microphone audio, transcribes locally through `whisper.cpp`, copies the result, and optionally pastes it.
- `fast-dictate-app`: a menu bar app with fixed-duration presets.
- `FastDictateCore`: shared logic for options, presets, audio recording, transcription, transcript cleaning, and pasteboard integration.
- `scripts/build-app.sh`: a script that builds and installs `~/Applications/Fast Dictate.app`.

## Core User Journeys

### Journey 1: Quick Dictation

1. User focuses a notes app, text editor, browser field, or chat box.
2. User opens the `Dictate` menu bar item.
3. User chooses `Dictate 8 Seconds`.
4. App records locally.
5. App transcribes locally.
6. App copies the transcript and pastes it if paste mode is enabled.

### Journey 2: Long Voice Note

1. User focuses a notes app or blank document.
2. User chooses `Long Voice Note 5 Minutes` or `Extended Voice Note 15 Minutes`.
3. App records locally for the selected duration.
4. App transcribes the full audio with the local model.
5. App inserts the text into the target app.

### Journey 3: CLI Automation

1. User runs `fast-dictate --duration 60 --paste`.
2. CLI records and transcribes locally.
3. CLI prints the transcript and copies it.
4. If requested, CLI pastes it through macOS automation.

## Functional Requirements

### Recording

- The app must request microphone permission on first use.
- The app must record fixed-duration audio presets.
- The app must clean up temporary audio files after transcription unless retention is explicitly requested by CLI flag.

### Transcription

- The default engine must use `whisper.cpp` locally.
- The app must auto-detect the local `whisper.cpp` binary and `small.en` model paths used by this machine.
- Users must be able to override model and binary paths through environment variables or CLI flags.
- Empty transcripts must produce a clear error.

### Output

- The transcript must be copied to the clipboard by default.
- Optional paste must insert into the active app.
- The menu bar app must show success or error feedback after each run.

### Long Voice Notes

- The app must expose presets for 1 minute, 5 minutes, and 15 minutes.
- Long note presets must use the same local transcription and paste path as short dictation.
- The UI must make clear that fixed-duration capture is active so users know how long they can speak.

## UX Requirements

- The product should feel like a Mac utility, not a web dashboard.
- The menu bar label should make recording state visible.
- The landing page should communicate privacy, local execution, and long-note support without generic AI imagery.
- The icon should suggest voice capture, local processing, and text output.

## Technical Requirements

- macOS 13 or later.
- Swift Package Manager build.
- `whisper.cpp` with Metal support on Apple Silicon.
- No network dependency in the transcription path.
- Self-tests must cover options, transcript cleaning, app files, long note presets, and product documentation/front-end artifacts.

## Success Metrics

- Time from launch to first successful transcript under 2 minutes after dependencies are installed.
- Short dictation path works with `fast-dictate --duration 8`.
- Menu bar app builds and installs through `scripts/build-app.sh`.
- Long voice notes can run for at least 15 minutes without code changes.
- Users can understand the product from the README and landing page without opening source files.

## Risks

- Fixed-duration long notes can waste time if the user finishes early.
- Very long recordings may use more memory and produce slower final transcription on an M1 MacBook Air.
- AppleScript paste requires Accessibility permission and can fail if the target app changes focus.
- `whisper.cpp` command names may change across versions.

## Roadmap

### V0.1: Local Utility

- CLI dictation.
- Menu bar fixed-duration presets.
- Local `whisper.cpp` setup.
- Public GitHub repo.

### V0.2: Better Long Notes

- Start/stop recording instead of fixed duration only.
- Progress indicator for long captures.
- Save transcript history locally.
- Add `.icns` app icon to the installed bundle.

### V0.3: Speed And Quality

- Benchmark model sizes on M1.
- Add MLX Whisper engine option.
- Add automatic punctuation cleanup profiles.
- Add hotkey support.

## Open Questions

- Should long notes stream confirmed text as they finish, or paste only once at the end?
- Should the app keep a local transcript history by default?
- Should the next UI be a small popover recorder, a full preferences window, or both?
