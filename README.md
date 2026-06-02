# Fast Dictation

Local-first Mac dictation MVP for an M1 MacBook Air with 16GB RAM.

It records microphone audio, transcribes it locally through `whisper.cpp`, copies the transcript to the clipboard, and can paste into the active app.

## Install Dependencies

```sh
brew install cmake
git clone https://github.com/ggerganov/whisper.cpp ~/Code/whisper.cpp
make -C ~/Code/whisper.cpp
```

Download a model:

```sh
bash ~/Code/whisper.cpp/models/download-ggml-model.sh small.en
```

The app auto-detects these default paths on this machine:

```sh
$HOME/Code/whisper.cpp/build/bin/whisper-cli
$HOME/Code/whisper.cpp/models/ggml-small.en.bin
```

You can override them with `FAST_DICTATE_WHISPER`, `FAST_DICTATE_MODEL`, `--whisper`, or `--model`.

## Build

```sh
swift build -c release
```

Run self-tests:

```sh
swift run fast-dictate-selftest
```

## Run

Copy transcript only:

```sh
.build/release/fast-dictate --duration 8
```

Copy and paste into the active app:

```sh
.build/release/fast-dictate --duration 8 --paste
```

The first run will request microphone permission. `--paste` may require Accessibility permission for your terminal in System Settings > Privacy & Security > Accessibility.

## Mac App

Build and install the menu bar app:

```sh
scripts/build-app.sh
```

Open it:

```sh
open "$HOME/Applications/Fast Dictate.app"
```

Use the `Dictate` menu bar item, then choose one of the presets:

- `Dictate 8 Seconds`
- `Voice Note 1 Minute`
- `Long Voice Note 5 Minutes`
- `Extended Voice Note 15 Minutes`

The app copies the transcript and pastes it into the active app when `Paste After Dictation` is checked. For long voice notes, leave the target note app focused before starting so the final transcript lands in the right place.

The first app run will request Microphone permission. Pasting may require Accessibility permission for Fast Dictate in System Settings > Privacy & Security > Accessibility.

## Current MVP Scope

- Local-only transcription.
- Fixed-duration recording, including long voice note presets up to 15 minutes.
- Clipboard copy by default.
- Optional active-app paste.
- Swappable engine boundary for a future MLX or menu bar wrapper.

## Next Step

Add start/stop recording so long voice notes do not need a fixed duration.
