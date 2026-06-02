# Long Voice Notes And GitHub Publish Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add long voice note presets to the Mac app and publish the project to GitHub under `sgk-ctrl`.

**Architecture:** Add a small `DictationPreset` value type to `FastDictateCore` so the app menu and tests share the same duration definitions. Keep recording fixed-duration for this iteration, with 1-minute, 5-minute, and 15-minute presets, then initialize git and push a new GitHub repository.

**Tech Stack:** Swift Package Manager, Swift 6, AppKit, `gh` CLI, git.

---

### Task 1: Long Voice Note Presets

**Files:**
- Create: `Sources/FastDictateCore/DictationPreset.swift`
- Modify: `Sources/FastDictateApp/main.swift`
- Modify: `Tests/FastDictateTests/main.swift`

- [x] **Step 1: Write failing self-test**

Add `testLongVoiceNotePresetsExist()` requiring quick, note, long note, and extended note presets with 5-minute and 15-minute durations.

- [x] **Step 2: Verify red**

Run: `swift run fast-dictate-selftest`

Expected: compile failure because `DictationPreset` is missing.

- [x] **Step 3: Implement preset type and menu wiring**

Create `DictationPreset` in core and build menu items from `DictationPreset.all`.

### Task 2: Docs And Verification

**Files:**
- Modify: `README.md`

- [x] **Step 1: Run self-tests**

Run: `swift run fast-dictate-selftest`

Expected: all self-tests pass.

- [x] **Step 2: Build and install app**

Run: `scripts/build-app.sh`

Expected: `/Users/SGK/Applications/Fast Dictate.app` exists.

### Task 3: GitHub Publish

**Files:**
- Create: `.gitignore`

- [ ] **Step 1: Initialize git and inspect status**

Run: `git init`, `git status`, `git diff --stat`, and `git log --oneline -10`.

- [ ] **Step 2: Commit code**

Run: `git add . && git commit -m "feat: add local Mac dictation app"`.

- [ ] **Step 3: Create GitHub repo and push**

Run: `gh repo create sgk-ctrl/fast-dictation --public --source=. --remote=origin --push`.
