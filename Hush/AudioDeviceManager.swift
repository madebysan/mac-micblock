import Foundation
import CoreAudio
import SimplyCoreAudio

// Handles all audio device operations: listing devices, switching, detecting usage
class AudioDeviceManager {
    // SimplyCoreAudio instance - manages CoreAudio for us
    private let coreAudio = SimplyCoreAudio()

    // Store the user's real microphone so we can switch back to it
    private var savedRealMicID: AudioObjectID?

    // Key for persisting the real mic choice
    private let savedMicKey = "savedRealMicrophoneUID"

    init() {
        // Load the saved real mic on init
        loadSavedRealMic()
    }

    // MARK: - Device Detection

    // Check if BlackHole is installed (any variant)
    var isBlackHoleInstalled: Bool {
        return findBlackHoleDevice() != nil
    }

    // Check if the current default input is BlackHole (blocked state)
    var isUsingNullDevice: Bool {
        guard let defaultInput = coreAudio.defaultInputDevice else { return false }
        let name = defaultInput.name.lowercased()
        return name.contains("blackhole")
    }

    // Get the name of the current input device
    var currentInputDeviceName: String? {
        return coreAudio.defaultInputDevice?.name
    }

    // Check if the microphone is currently being used by any app
    var isMicrophoneInUse: Bool {
        guard let defaultInput = coreAudio.defaultInputDevice else { return false }
        return defaultInput.isRunningSomewhere
    }

    // MARK: - Device Switching

    // Switch to BlackHole (null device) to block the mic
    func switchToNullDevice() {
        // First, save the current real mic so we can restore it later
        saveCurrentRealMic()

        // Find BlackHole
        guard let blackhole = findBlackHoleDevice() else {
            print("BlackHole not found! Cannot block mic.")
            return
        }

        // Set BlackHole as the default input device
        blackhole.isDefaultInputDevice = true
        if blackhole.isDefaultInputDevice {
            print("Switched to BlackHole - mic is now blocked")
        } else {
            print("Failed to switch to BlackHole")
        }
    }

    // Switch back to the real microphone
    func switchToRealMic() {
        guard let realMic = findRealMicrophone() else {
            print("Could not find real microphone to switch to")
            return
        }

        realMic.isDefaultInputDevice = true
        if realMic.isDefaultInputDevice {
            print("Switched to real mic: \(realMic.name)")
        } else {
            print("Failed to switch to real mic")
        }
    }

    // MARK: - Debug Helpers

    // List all input devices (useful for debugging)
    func listAllInputDevices() -> [String] {
        return coreAudio.allInputDevices.map { device in
            let inUse = device.isRunningSomewhere ? " (IN USE)" : ""
            return "\(device.name)\(inUse)"
        }
    }

    // MARK: - Private Methods

    private func findBlackHoleDevice() -> AudioDevice? {
        // Look for any BlackHole variant (2ch, 16ch, etc.)
        return coreAudio.allInputDevices.first { device in
            device.name.lowercased().contains("blackhole")
        }
    }

    private func findRealMicrophone() -> AudioDevice? {
        // First, try to use the saved mic
        if let savedID = savedRealMicID,
           let savedDevice = coreAudio.allInputDevices.first(where: { $0.id == savedID }) {
            return savedDevice
        }

        // Try to load from UserDefaults by UID
        if let savedUID = UserDefaults.standard.string(forKey: savedMicKey),
           let savedDevice = coreAudio.allInputDevices.first(where: { $0.uid == savedUID }) {
            savedRealMicID = savedDevice.id
            return savedDevice
        }

        // Otherwise, find the first non-BlackHole input device
        // Prefer built-in devices over external ones
        let realMics = coreAudio.allInputDevices.filter { device in
            !device.name.lowercased().contains("blackhole")
        }

        // Try to find built-in mic first
        if let builtIn = realMics.first(where: { $0.name.contains("MacBook") || $0.name.contains("Built-in") }) {
            return builtIn
        }

        // Fall back to first available
        return realMics.first
    }

    private func saveCurrentRealMic() {
        // Only save if we're currently using a real mic (not BlackHole)
        guard let currentDevice = coreAudio.defaultInputDevice,
              !currentDevice.name.lowercased().contains("blackhole") else {
            return
        }

        savedRealMicID = currentDevice.id

        // Also persist the UID so we can restore across app launches
        if let uid = currentDevice.uid {
            UserDefaults.standard.set(uid, forKey: savedMicKey)
        }
    }

    private func loadSavedRealMic() {
        if let savedUID = UserDefaults.standard.string(forKey: savedMicKey),
           let savedDevice = coreAudio.allInputDevices.first(where: { $0.uid == savedUID }) {
            savedRealMicID = savedDevice.id
        }
    }
}
