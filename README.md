<p align="center">
  <img src="assets/app-icon.png" width="128" height="128" alt="Hush app icon">
</p>

<h1 align="center">Hush</h1>

<p align="center">A macOS menu bar app that disconnects your real microphone system-wide<br>
by swapping it with a silent virtual device.</p>

<p align="center">macOS 13+ · Apple Silicon & Intel</p>
<p align="center"><a href="https://github.com/madebysan/hush/releases/latest"><strong>Download Hush</strong></a></p>

## What it does

Hush gives you a one-click kill switch for your microphone, right in your menu bar:

- **Grey mic icon** – Microphone available (not in use)
- **Green mic icon** – Microphone is actively in use by an app
- **Red mic icon** – Microphone is disconnected (apps receive silence)

Click the icon to toggle. Hush remembers your preference across restarts.

## How it works

Hush uses [BlackHole](https://existential.audio/blackhole/), a free open-source virtual audio driver, as a decoy input device. When you activate blocking:

1. Hush saves which microphone you're currently using
2. It replaces your macOS default input device with BlackHole – a null audio device that can only ever produce silence
3. Apps recording from the default input are now connected to a device that has no microphone hardware at all

When you deactivate, Hush switches back to your real microphone.

**This is stronger than muting.** A muted mic is still your active input device – it could be unmuted by a bug, an app, or the OS. Hush removes your real mic from the equation entirely. Apps aren't talking to a silenced microphone – they're talking to a virtual device that has no audio to give. There's nothing to unmute.

## What this is good for

- **One-click mic disconnect** across all apps, no digging through System Settings
- **Stronger than app-level mute** – your real mic isn't the input device at all, not just silenced
- **Hot-mic prevention** – Zoom/Teams left running in the background can't hear you
- **Visible status** – always know when any app is using the mic via the menu bar icon
- Peace of mind for everyday use

## Limitations

Hush is a **practical privacy tool, not a security tool**. It's worth understanding the boundaries:

- **Apps can select a specific device.** Any app that explicitly targets a particular audio device (rather than using the system default) will still reach your real microphone. Most apps use the default, but some audio-focused apps don't.
- **It doesn't revoke permissions.** macOS per-app microphone permissions (System Settings > Privacy & Security > Microphone) are enforced at the kernel level and are stronger. Hush operates in userspace and doesn't change these permissions.
- **Already-recording apps may not be affected.** If an app opened a specific device before you activated blocking, it may continue recording from that device.
- **It won't stop kernel-level threats.** If your system is compromised at the driver or kernel level, no userspace app can protect you.

For defense in depth, use Hush alongside macOS's built-in per-app microphone permissions. They complement each other – Hush for quick daily control, system permissions for hard enforcement.

## Requirements

- macOS 13.0 (Ventura) or later
- [BlackHole 2ch](https://existential.audio/blackhole/) (free virtual audio driver)

## Installation

1. Download and install [BlackHole 2ch](https://existential.audio/blackhole/)
2. Restart your Mac after installing BlackHole
3. Download **Hush.dmg** from the [latest release](https://github.com/madebysan/hush/releases/latest)
4. Open the DMG and drag Hush to your Applications folder
5. Launch Hush – it will appear in your menu bar

The app is signed and notarized by Apple.

## Usage

- **Click the menu bar icon** to toggle mic blocking on/off
- **Right-click** (or click and hold) to access the menu:
  - See current microphone status
  - See which input device is active
  - Enable/disable launch at login
  - Quit the app

## Building from source

Requires Xcode 15 or later.

```bash
git clone https://github.com/madebysan/hush.git
cd hush
xcodebuild -project Hush.xcodeproj -scheme Hush -configuration Release
# The app will be in build/Release/Hush.app
```

## Privacy

Hush runs entirely on your Mac. No data collection, no network connections, no telemetry. The app only:

- Monitors which audio input device is active
- Detects when your microphone is in use (via CoreAudio)
- Switches between audio input devices
- Stores your preferences locally (mute state, launch-at-login, saved microphone)

## Feedback

Found a bug or have a feature idea? [Open an issue](https://github.com/madebysan/hush/issues).

## Credits

- [SimplyCoreAudio](https://github.com/rnine/SimplyCoreAudio) for audio device management
- [BlackHole](https://existential.audio/blackhole/) virtual audio driver

## License

[MIT](LICENSE)

---

Made by [santiagoalonso.com](https://santiagoalonso.com)
