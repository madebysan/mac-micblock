import SwiftUI

// The main app entry point - uses MenuBarExtra for a menu bar-only app
@main
struct HushApp: App {
    // StateObject keeps the view model alive for the app's lifetime
    @StateObject private var viewModel = HushViewModel()

    var body: some Scene {
        // MenuBarExtra creates the menu bar icon and dropdown
        MenuBarExtra {
            // The dropdown menu content
            MenuBarDropdownView(viewModel: viewModel)
        } label: {
            // The icon that appears in the menu bar
            Image(systemName: viewModel.menuBarIconName)
                .symbolRenderingMode(.palette)
                .foregroundStyle(viewModel.iconColor)
        }
        // .menu style means click shows dropdown (vs .window which shows a window)
        .menuBarExtraStyle(.menu)
    }
}

// The dropdown menu that appears when you click the icon
struct MenuBarDropdownView: View {
    @ObservedObject var viewModel: HushViewModel

    var body: some View {
        // Show current state at top
        Text(viewModel.statusText)
            .font(.headline)

        Divider()

        // Toggle button - only shown when not blocked (can't toggle while in use)
        Button(viewModel.isBlocked ? "Unblock Microphone" : "Block Microphone") {
            viewModel.toggleBlock()
        }
        .keyboardShortcut("m", modifiers: [.command])

        Divider()

        // Show which device is being used (helpful for debugging)
        if let deviceName = viewModel.currentInputDeviceName {
            Text("Input: \(deviceName)")
                .font(.caption)
                .foregroundColor(.secondary)

            Divider()
        }

        // Settings section
        Toggle("Launch at Login", isOn: $viewModel.launchAtLogin)

        Divider()

        Button("Quit Hush") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q", modifiers: [.command])
    }
}
