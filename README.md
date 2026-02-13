# MicBlock

A macOS menu bar app that disconnects your real microphone system-wide by swapping it with a silent virtual device.

## What it does

MicBlock gives you a one-click kill switch for your microphone, right in your menu bar:

- **Grey mic icon** — Microphone available (not in use)
- **Green mic icon** — Microphone is actively in use by an app
- **Red mic icon** — Microphone is disconnected (apps receive silence)

Click the icon to toggle. MicBlock remembers your preference across restarts.

## How it works

MicBlock uses [BlackHole](https://existential.audio/blackhole/), a free open-source virtual audio driver, as a decoy input device. When you activate blocking:

1. MicBlock saves which microphone you're currently using
2. It replaces your macOS default input device with BlackHole — a null audio device that can only ever produce silence
3. Apps recording from the default input are now connected to a device that has no microphone hardware at all

When you deactivate, MicBlock switches back to your real microphone.

**This is stronger than muting.** A muted mic is still your active input device — it could be unmuted by a bug, an app, or the OS. MicBlock removes your real mic from the equation entirely. Apps aren't talking to a silenced microphone — they're talking to a virtual device that has no audio to give. There's nothing to unmute.

## What this is good for

- **One-click mic disconnect** across all apps, no digging through System Settings
- **Stronger than app-level mute** — your real mic isn't the input device at all, not just silenced
- **Hot-mic prevention** — Zoom/Teams left running in the background can't hear you
- **Visible status** — always know when any app is using the mic via the menu bar icon
- Peace of mind for everyday use

## Limitations

MicBlock is a **practical privacy tool, not a security tool**. It's worth understanding the boundaries:

- **Apps can select a specific device.** Any app that explicitly targets a particular audio device (rather than using the system default) will still reach your real microphone. Most apps use the default, but some audio-focused apps don't.
- **It doesn't revoke permissions.** macOS per-app microphone permissions (System Settings > Privacy & Security > Microphone) are enforced at the kernel level and are stronger. MicBlock operates in userspace and doesn't change these permissions.
- **Already-recording apps may not be affected.** If an app opened a specific device before you activated blocking, it may continue recording from that device.
- **It won't stop kernel-level threats.** If your system is compromised at the driver or kernel level, no userspace app can protect you.

For defense in depth, use MicBlock alongside macOS's built-in per-app microphone permissions. They complement each other — MicBlock for quick daily control, system permissions for hard enforcement.

## Requirements

- macOS 13.0 (Ventura) or later
- [BlackHole 2ch](https://existential.audio/blackhole/) (free virtual audio driver)

## Installation

1. Download and install [BlackHole 2ch](https://existential.audio/blackhole/)
2. Restart your Mac after installing BlackHole
3. Download MicBlock.app and move it to your Applications folder
4. Launch MicBlock — it will appear in your menu bar

## Usage

- **Click the menu bar icon** to toggle mic muting on/off
- **Right-click** (or click and hold) to access the menu:
  - See current microphone status
  - See which input device is active
  - Enable/disable launch at login
  - Quit the app

## Building from source

Requires Xcode 15 or later.

```bash
git clone https://github.com/madebysan/micblock.git
cd micblock
xcodebuild -project MicBlock.xcodeproj -scheme MicBlock -configuration Release
# The app will be in build/Release/MicBlock.app
```

## Privacy

MicBlock runs entirely on your Mac. No data collection, no network connections, no telemetry. The app only:

- Monitors which audio input device is active
- Detects when your microphone is in use (via CoreAudio)
- Switches between audio input devices
- Stores your preferences locally (mute state, launch-at-login, saved microphone)

## License

MIT License — feel free to use, modify, and distribute.

## Credits

- [SimplyCoreAudio](https://github.com/rnine/SimplyCoreAudio) for audio device management
- [BlackHole](https://existential.audio/blackhole/) virtual audio driver
