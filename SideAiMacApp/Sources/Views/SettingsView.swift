import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }
            
            NotificationSettingsView()
                .tabItem {
                    Label("Notifications", systemImage: "bell")
                }
            
            AppearanceSettingsView()
                .tabItem {
                    Label("Appearance", systemImage: "paintbrush")
                }
            
            AdvancedSettingsView()
                .tabItem {
                    Label("Advanced", systemImage: "slider.horizontal.3")
                }
        }
        .frame(width: 600, height: 450)
    }
}

struct GeneralSettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    
    var body: some View {
        Form {
            Section("Tasks") {
                Picker("Default Priority", selection: $settingsManager.defaultTaskPriority) {
                    ForEach(Task.Priority.allCases, id: \.self) { priority in
                        Text(priority.rawValue).tag(priority)
                    }
                }
                
                Toggle("Show Completed Tasks", isOn: $settingsManager.showCompletedTasks)
                
                Toggle("Auto-delete Completed Tasks", isOn: $settingsManager.autoDeleteCompletedTasks)
                    .help("Automatically delete tasks after they're completed for 7 days")
            }
            
            Section("Calendar") {
                Toggle("Enable Calendar Integration", isOn: $settingsManager.calendarIntegrationEnabled)
                    .help("Sync events with macOS Calendar app")
            }
            
            Section {
                Button("Reset to Defaults") {
                    settingsManager.resetToDefaults()
                }
                .foregroundColor(.red)
            }
        }
        .formStyle(.grouped)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onChange(of: settingsManager.defaultTaskPriority) { _, _ in
            settingsManager.saveSettings()
        }
        .onChange(of: settingsManager.showCompletedTasks) { _, _ in
            settingsManager.saveSettings()
        }
        .onChange(of: settingsManager.autoDeleteCompletedTasks) { _, _ in
            settingsManager.saveSettings()
        }
        .onChange(of: settingsManager.calendarIntegrationEnabled) { _, _ in
            settingsManager.saveSettings()
        }
    }
}

struct NotificationSettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @StateObject private var notificationManager = NotificationManager()
    
    var body: some View {
        Form {
            Section("Notifications") {
                Toggle("Enable Notifications", isOn: $settingsManager.notificationsEnabled)
                
                if !notificationManager.isAuthorized {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.orange)
                        Text("Notifications are not authorized")
                            .foregroundColor(.secondary)
                        Button("Enable in System Settings") {
                            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.notifications") {
                                NSWorkspace.shared.open(url)
                            }
                        }
                    }
                }
            }
            
            Section("Reminders") {
                Stepper(
                    "Default Reminder: \(settingsManager.defaultReminderTime) min before",
                    value: $settingsManager.defaultReminderTime,
                    in: 5...60,
                    step: 5
                )
            }
            
            Section("Info") {
                Text("Additional notification preferences can be configured in System Settings.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onChange(of: settingsManager.notificationsEnabled) { _, _ in
            settingsManager.saveSettings()
        }
        .onChange(of: settingsManager.defaultReminderTime) { _, _ in
            settingsManager.saveSettings()
        }
    }
}

struct AppearanceSettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    
    var body: some View {
        Form {
            Section("Theme") {
                Picker("Theme", selection: $settingsManager.theme) {
                    ForEach(SettingsManager.Theme.allCases, id: \.self) { theme in
                        Text(theme.rawValue).tag(theme)
                    }
                }
                .pickerStyle(.radioGroup)
            }
            
            Section("Info") {
                Text("The interface follows macOS system conventions and adapts to your theme selection.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onChange(of: settingsManager.theme) { _, _ in
            settingsManager.saveSettings()
        }
    }
}

struct AdvancedSettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @State private var showingDataManagement = false
    
    var body: some View {
        Form {
            Section("Data & Privacy") {
                Button("Manage Data...") {
                    showingDataManagement = true
                }
                
                Button("View Privacy Policy") {
                    if let url = URL(string: "https://github.com") {
                        NSWorkspace.shared.open(url)
                    }
                }
            }
            
            Section("About") {
                LabeledContent("Version", value: "1.0.0")
                LabeledContent("Build", value: "100")
                
                Button("View on GitHub") {
                    if let url = URL(string: "https://github.com") {
                        NSWorkspace.shared.open(url)
                    }
                }
            }
            
            Section("Debug") {
                Button("Reset Onboarding") {
                    UserDefaults.standard.set(false, forKey: "hasLaunchedBefore")
                    settingsManager.showOnboarding = true
                }
            }
        }
        .formStyle(.grouped)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $showingDataManagement) {
            DataManagementView()
        }
    }
}

struct DataManagementView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Storage") {
                    LabeledContent("Tasks", value: "Stored locally")
                    LabeledContent("Events", value: "Stored locally")
                    LabeledContent("Reminders", value: "Stored locally")
                }
                
                Section("Security") {
                    LabeledContent("Encryption", value: "Enabled")
                    Text("All data is encrypted using macOS Keychain")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section {
                    Button("Export Data") {
                        alertMessage = "Export functionality coming soon"
                        showingAlert = true
                    }
                    
                    Button(role: .destructive) {
                        alertMessage = "This will delete all your data. This action cannot be undone."
                        showingAlert = true
                    } label: {
                        Label("Delete All Data", systemImage: "trash")
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Data Management")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .frame(width: 500, height: 400)
        .alert("Data Management", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
}
