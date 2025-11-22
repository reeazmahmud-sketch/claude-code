import SwiftUI

@main
struct SideAiMacAppApp: App {
    @StateObject private var taskManager = TaskManager()
    @StateObject private var settingsManager = SettingsManager()
    @StateObject private var notificationManager = NotificationManager()
    
    init() {
        // Request notification permissions on startup
        NotificationManager.requestAuthorization()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(taskManager)
                .environmentObject(settingsManager)
                .environmentObject(notificationManager)
                .frame(minWidth: 800, minHeight: 600)
                .onAppear {
                    // Check if first launch for onboarding
                    if settingsManager.isFirstLaunch {
                        settingsManager.showOnboarding = true
                    }
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commands {
            AppMenuCommands()
        }
        
        Settings {
            SettingsView()
                .environmentObject(settingsManager)
        }
    }
}

// App Menu Commands
struct AppMenuCommands: Commands {
    var body: some Commands {
        CommandGroup(replacing: .appInfo) {
            Button("About SideAi") {
                NSApp.orderFrontStandardAboutPanel(
                    options: [
                        NSApplication.AboutPanelOptionKey.applicationName: "SideAi",
                        NSApplication.AboutPanelOptionKey.applicationVersion: "1.0.0",
                        NSApplication.AboutPanelOptionKey.credits: NSAttributedString(
                            string: "A productivity app for macOS",
                            attributes: [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 11)]
                        )
                    ]
                )
            }
        }
    }
}
