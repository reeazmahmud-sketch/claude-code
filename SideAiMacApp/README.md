# SideAi - macOS Productivity App

A modern, elegant macOS productivity application built with Swift and SwiftUI, inspired by Side.ai.

## Features

### 🎯 Task Management
- Create, edit, and delete tasks with ease
- Set priorities (Low, Medium, High, Urgent)
- Add due dates and reminders
- Track task completion status
- Search and filter tasks
- Tag-based organization

### 📅 Schedule & Events
- Visual calendar interface
- Create and manage events
- Set event locations and time ranges
- All-day event support
- Event reminders (15 minutes before)
- Day, week, and month views

### 🔔 Smart Reminders
- Customizable reminder dates and times
- Repeating reminders (daily, weekly, monthly)
- Overdue reminder tracking
- Integration with macOS notifications

### ⚙️ Settings & Customization
- Theme selection (Light, Dark, System)
- Notification preferences
- Default task priorities
- Calendar integration options
- Data management and privacy controls

### 🔐 Secure Data Storage
- All data encrypted using macOS Keychain
- Local storage with encryption
- Privacy-focused design
- No cloud syncing (data stays on your device)

### 🎨 Elegant User Experience
- Clean, modern SwiftUI interface
- Intuitive navigation
- Smooth animations
- Native macOS integration
- Dock and menu bar support
- Onboarding experience for new users

## System Requirements

- macOS 13.0 (Ventura) or later
- Swift 6.0 or later
- Xcode 15.0 or later (recommended for development)

## Building from Source

**Note:** This application uses SwiftUI and AppKit, which are macOS-specific frameworks. It can only be built and run on macOS.

### Using Swift Package Manager (macOS only)

1. Clone the repository:
```bash
cd SideAiMacApp
```

2. Build the application:
```bash
swift build
```

3. Run the application:
```bash
swift run
```

4. For release build:
```bash
swift build -c release
```

### Using Xcode (Recommended)

1. Open the `SideAiMacApp` directory in Xcode
2. Select "File" → "Open" and choose the `Package.swift` file
3. Build and run using Cmd+R

## Running Tests

```bash
swift test
```

Or in Xcode: Cmd+U

## Project Structure

```
SideAiMacApp/
├── Package.swift           # Swift package configuration
├── Sources/
│   ├── main.swift         # App entry point
│   ├── Models/            # Data models
│   │   └── Task.swift     # Task, Event, and Reminder models
│   ├── Views/             # SwiftUI views
│   │   ├── ContentView.swift
│   │   ├── TasksView.swift
│   │   ├── ScheduleView.swift
│   │   ├── RemindersView.swift
│   │   ├── SettingsView.swift
│   │   └── OnboardingView.swift
│   ├── ViewModels/        # Business logic
│   │   ├── TaskManager.swift
│   │   └── SettingsManager.swift
│   ├── Services/          # Core services
│   │   ├── StorageService.swift
│   │   └── NotificationManager.swift
│   └── Utilities/         # Helper utilities
└── Tests/                 # Unit tests
```

## Architecture

The app follows the MVVM (Model-View-ViewModel) architecture pattern:

- **Models**: Define data structures (Task, Event, Reminder)
- **Views**: SwiftUI views for UI components
- **ViewModels**: Manage state and business logic (TaskManager, SettingsManager)
- **Services**: Handle data persistence, notifications, and system integration

## Key Technologies

- **SwiftUI**: Modern declarative UI framework
- **Combine**: Reactive programming for state management
- **UserNotifications**: macOS notification integration
- **Security Framework**: Keychain integration for secure storage
- **FileManager**: Local data persistence

## Privacy & Security

- All user data is stored locally on your Mac
- Data is encrypted using macOS Keychain
- No telemetry or analytics
- No internet connection required
- No account or sign-up needed

## Customization

You can customize various aspects of the app through the Settings panel:

1. **General**: Default task priorities, completed task visibility
2. **Notifications**: Enable/disable notifications, reminder timing
3. **Appearance**: Theme selection, interface preferences
4. **Advanced**: Data management, privacy settings

## Contributing

This project is part of a demonstration. Feel free to explore and learn from the code.

## License

See the LICENSE.md file in the parent repository.

## Acknowledgments

Inspired by Side.ai and modern productivity tools.
