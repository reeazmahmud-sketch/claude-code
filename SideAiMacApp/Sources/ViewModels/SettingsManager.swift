import Foundation
import SwiftUI

@MainActor
class SettingsManager: ObservableObject {
    @Published var isFirstLaunch: Bool
    @Published var showOnboarding: Bool = false
    @Published var theme: Theme = .system
    @Published var notificationsEnabled: Bool = true
    @Published var defaultTaskPriority: Task.Priority = .medium
    @Published var calendarIntegrationEnabled: Bool = false
    @Published var showCompletedTasks: Bool = true
    @Published var autoDeleteCompletedTasks: Bool = false
    @Published var defaultReminderTime: Int = 15 // minutes before
    
    private let userDefaults = UserDefaults.standard
    
    enum Theme: String, CaseIterable {
        case light = "Light"
        case dark = "Dark"
        case system = "System"
        
        var colorScheme: ColorScheme? {
            switch self {
            case .light: return .light
            case .dark: return .dark
            case .system: return nil
            }
        }
    }
    
    init() {
        // Check if first launch
        self.isFirstLaunch = !userDefaults.bool(forKey: "hasLaunchedBefore")
        
        // Load settings
        loadSettings()
        
        // Mark as launched
        if isFirstLaunch {
            userDefaults.set(true, forKey: "hasLaunchedBefore")
        }
    }
    
    private func loadSettings() {
        if let themeString = userDefaults.string(forKey: "theme"),
           let theme = Theme(rawValue: themeString) {
            self.theme = theme
        }
        
        notificationsEnabled = userDefaults.bool(forKey: "notificationsEnabled")
        if userDefaults.object(forKey: "notificationsEnabled") == nil {
            notificationsEnabled = true // Default to true
        }
        
        if let priorityString = userDefaults.string(forKey: "defaultTaskPriority"),
           let priority = Task.Priority(rawValue: priorityString) {
            self.defaultTaskPriority = priority
        }
        
        calendarIntegrationEnabled = userDefaults.bool(forKey: "calendarIntegrationEnabled")
        showCompletedTasks = userDefaults.bool(forKey: "showCompletedTasks")
        if userDefaults.object(forKey: "showCompletedTasks") == nil {
            showCompletedTasks = true // Default to true
        }
        
        autoDeleteCompletedTasks = userDefaults.bool(forKey: "autoDeleteCompletedTasks")
        
        defaultReminderTime = userDefaults.integer(forKey: "defaultReminderTime")
        if defaultReminderTime == 0 {
            defaultReminderTime = 15 // Default to 15 minutes
        }
    }
    
    func saveSettings() {
        userDefaults.set(theme.rawValue, forKey: "theme")
        userDefaults.set(notificationsEnabled, forKey: "notificationsEnabled")
        userDefaults.set(defaultTaskPriority.rawValue, forKey: "defaultTaskPriority")
        userDefaults.set(calendarIntegrationEnabled, forKey: "calendarIntegrationEnabled")
        userDefaults.set(showCompletedTasks, forKey: "showCompletedTasks")
        userDefaults.set(autoDeleteCompletedTasks, forKey: "autoDeleteCompletedTasks")
        userDefaults.set(defaultReminderTime, forKey: "defaultReminderTime")
    }
    
    func completeOnboarding() {
        showOnboarding = false
        isFirstLaunch = false
    }
    
    func resetToDefaults() {
        theme = .system
        notificationsEnabled = true
        defaultTaskPriority = .medium
        calendarIntegrationEnabled = false
        showCompletedTasks = true
        autoDeleteCompletedTasks = false
        defaultReminderTime = 15
        saveSettings()
    }
}
