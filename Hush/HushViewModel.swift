import SwiftUI
import Combine
import ServiceManagement

// The three possible states for the mic icon
enum MicState {
    case available  // Grey - real mic is default, not in use
    case inUse      // Green - real mic is actively being used
    case blocked    // Red - null device is default, apps get silence
}

// Manages all the app state and coordinates with the audio system
@MainActor
class HushViewModel: ObservableObject {
    // The current state determines the icon color
    @Published private(set) var state: MicState = .available

    // Whether the user has enabled launch at login
    @Published var launchAtLogin: Bool = false {
        didSet {
            updateLaunchAtLogin()
        }
    }

    // The audio manager handles all the device switching
    private let audioManager = AudioDeviceManager()

    // Cancellables for Combine subscriptions
    private var cancellables = Set<AnyCancellable>()

    init() {
        // Check if BlackHole is installed on first launch
        checkBlackHoleInstallation()

        // Set up observers for mic-in-use detection
        setupMicUsageObserver()

        // Load saved preferences and restore the correct state
        loadPreferences()

        // Restore the state the user had before (blocked or not)
        restoreSavedBlockState()
    }

    // MARK: - Public Interface

    // Toggle between available (grey) and blocked (red)
    func toggleBlock() {
        if state == .blocked {
            // Currently blocked -> unblock (switch to real mic)
            audioManager.switchToRealMic()
            state = .available
        } else {
            // Currently available or in use -> block (switch to null device)
            audioManager.switchToNullDevice()
            state = .blocked
        }

        // Save which state we're in
        savePreferences()
    }

    // Whether mic is currently blocked
    var isBlocked: Bool {
        state == .blocked
    }

    // MARK: - Menu Bar Display

    // The SF Symbol name for the current state
    var menuBarIconName: String {
        switch state {
        case .available:
            return "mic"
        case .inUse:
            return "mic.fill"
        case .blocked:
            return "mic.slash"
        }
    }

    // The color for the menu bar icon
    var iconColor: Color {
        switch state {
        case .available:
            return .gray
        case .inUse:
            return .green
        case .blocked:
            return .red
        }
    }

    // Human-readable status for the dropdown
    var statusText: String {
        switch state {
        case .available:
            return "Microphone Available"
        case .inUse:
            return "Microphone In Use"
        case .blocked:
            return "Microphone Blocked"
        }
    }

    // Current input device name for display
    var currentInputDeviceName: String? {
        audioManager.currentInputDeviceName
    }

    // MARK: - Private Methods

    private func checkBlackHoleInstallation() {
        if !audioManager.isBlackHoleInstalled {
            // Show onboarding alert
            showBlackHoleInstallPrompt()
        }
    }

    private func showBlackHoleInstallPrompt() {
        // Run on main thread with slight delay to ensure app is ready
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let alert = NSAlert()
            alert.messageText = "BlackHole Audio Driver Required"
            alert.informativeText = "Hush needs BlackHole (a free virtual audio driver) to block your microphone.\n\nDownload BlackHole 2ch from the website, install it, then restart your Mac."
            alert.alertStyle = .informational
            alert.addButton(withTitle: "Open Download Page")
            alert.addButton(withTitle: "Later")

            let response = alert.runModal()

            if response == .alertFirstButtonReturn {
                if let url = URL(string: "https://existential.audio/blackhole/") {
                    NSWorkspace.shared.open(url)
                }
            }
        }
    }

    private func setupMicUsageObserver() {
        // Poll for mic usage every second
        // (SimplyCoreAudio provides this, but we'll use a simple polling approach first)
        Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.checkMicUsage()
            }
            .store(in: &cancellables)
    }

    private func checkMicUsage() {
        // Only check if we're not blocked
        guard state != .blocked else { return }

        if audioManager.isMicrophoneInUse {
            state = .inUse
        } else {
            state = .available
        }
    }

    private func restoreSavedBlockState() {
        // Check if user had blocking enabled before
        let wasBlocked = UserDefaults.standard.bool(forKey: "wasBlocked")

        if wasBlocked {
            // User wanted blocking - make sure BlackHole is active
            if !audioManager.isUsingNullDevice {
                audioManager.switchToNullDevice()
            }
            state = .blocked
        } else {
            // User did NOT want blocking - make sure real mic is active
            // This fixes the issue where BlackHole might be default for other reasons
            if audioManager.isUsingNullDevice {
                audioManager.switchToRealMic()
            }
            state = .available
        }
    }

    private func loadPreferences() {
        // Load launch at login state
        launchAtLogin = UserDefaults.standard.bool(forKey: "launchAtLogin")
    }

    private func savePreferences() {
        // Save whether we're blocked so we can restore on relaunch
        UserDefaults.standard.set(isBlocked, forKey: "wasBlocked")
    }

    private func updateLaunchAtLogin() {
        // Use the modern ServiceManagement API
        do {
            if launchAtLogin {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            UserDefaults.standard.set(launchAtLogin, forKey: "launchAtLogin")
        } catch {
            print("Failed to update launch at login: \(error)")
        }
    }
}
