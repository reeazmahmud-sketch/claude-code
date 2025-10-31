# Development Guide

## Overview

SideAi is a native macOS productivity application built using SwiftUI and Swift Package Manager. This guide provides detailed information for developers working on the project.

## Prerequisites

- **macOS 13.0+**: Required for running the application
- **Xcode 15.0+**: Recommended IDE for development
- **Swift 6.0+**: Language version
- **Git**: For version control

## Development Environment Setup

### 1. Clone and Setup

```bash
git clone <repository-url>
cd claude-code/SideAiMacApp
```

### 2. Open in Xcode

```bash
open Package.swift
```

Or use Xcode's File → Open menu to select the `Package.swift` file.

### 3. Build Configuration

The project uses Swift Package Manager with the following configuration:
- **Minimum Platform**: macOS 13.0
- **Swift Tools Version**: 6.0
- **Product Type**: Executable

## Project Architecture

### MVVM Pattern

The application follows the Model-View-ViewModel (MVVM) architecture:

```
┌─────────────────────────────────────────────────┐
│                    Views                         │
│  (SwiftUI - ContentView, TasksView, etc.)       │
└───────────────┬─────────────────────────────────┘
                │ @EnvironmentObject
                │ @StateObject
┌───────────────▼─────────────────────────────────┐
│                 ViewModels                       │
│  (TaskManager, SettingsManager)                  │
└───────────────┬─────────────────────────────────┘
                │
                │ Operates on
┌───────────────▼─────────────────────────────────┐
│                   Models                         │
│  (Task, ScheduleEvent, Reminder)                │
└─────────────────────────────────────────────────┘
                │
                │ Used by
┌───────────────▼─────────────────────────────────┐
│                  Services                        │
│  (StorageService, NotificationManager)          │
└─────────────────────────────────────────────────┘
```

### Directory Structure

```
SideAiMacApp/
├── Package.swift              # SPM configuration
├── README.md                  # User documentation
├── DEVELOPMENT.md            # This file
├── .gitignore                # Git ignore rules
│
├── Sources/
│   ├── main.swift            # App entry point (@main)
│   │
│   ├── Models/               # Data models
│   │   └── Task.swift        # Task, ScheduleEvent, Reminder
│   │
│   ├── Views/                # SwiftUI views
│   │   ├── ContentView.swift      # Main container
│   │   ├── TasksView.swift        # Task management UI
│   │   ├── ScheduleView.swift     # Calendar/schedule UI
│   │   ├── RemindersView.swift    # Reminders UI
│   │   ├── SettingsView.swift     # Settings UI
│   │   └── OnboardingView.swift   # First-run experience
│   │
│   ├── ViewModels/           # Business logic
│   │   ├── TaskManager.swift      # Task state management
│   │   └── SettingsManager.swift  # Settings state
│   │
│   ├── Services/             # Core services
│   │   ├── StorageService.swift      # Data persistence
│   │   └── NotificationManager.swift # Notifications
│   │
│   └── Utilities/            # Helper code (future)
│
└── Tests/                    # Unit tests
    ├── TaskTests.swift
    └── StorageServiceTests.swift
```

## Key Components

### 1. Models (`Models/Task.swift`)

**Task**: Represents a task with priority, due dates, and completion status
- Properties: id, title, description, dueDate, priority, isCompleted, tags, reminderDate
- Enum: Priority (Low, Medium, High, Urgent)

**ScheduleEvent**: Represents a calendar event
- Properties: id, title, description, startDate, endDate, location, isAllDay

**Reminder**: Represents a reminder with repeat options
- Properties: id, title, notes, reminderDate, isCompleted, repeatInterval
- Enum: RepeatInterval (None, Daily, Weekly, Monthly)

### 2. Views

All views are built with SwiftUI and follow Apple's Human Interface Guidelines.

**ContentView**: Main container with NavigationSplitView for sidebar navigation

**TasksView**: 
- Task list with filtering and search
- Add/edit task sheets
- Swipe actions for deletion

**ScheduleView**:
- Calendar picker (graphical style)
- Event list for selected date
- Add/edit event sheets

**RemindersView**:
- Reminder list with completion toggles
- Shows overdue reminders with warnings
- Add/edit reminder sheets

**SettingsView**:
- Tabbed settings interface
- General, Notifications, Appearance, Advanced tabs

**OnboardingView**:
- Multi-page introduction for new users
- Permission requests (notifications)

### 3. ViewModels

**TaskManager**: 
- Centralized state management for tasks, events, and reminders
- CRUD operations for all data types
- Notification scheduling integration
- Data persistence integration

**SettingsManager**:
- User preferences management
- Theme selection
- First-launch detection
- Settings persistence via UserDefaults

### 4. Services

**StorageService**:
- File-based storage with encryption
- Keychain integration for encryption keys
- JSON encoding/decoding with ISO8601 dates
- Separate storage for tasks, events, and reminders

**NotificationManager**:
- macOS UserNotifications framework integration
- Permission handling
- Notification scheduling and cancellation
- Badge count management

## Data Flow

### Adding a Task Example

```
1. User taps "+" button in TasksView
2. AddTaskView sheet appears
3. User fills in task details and taps "Add"
4. TaskManager.addTask() is called
5. Task is added to @Published tasks array
6. If reminder is set, NotificationManager schedules notification
7. StorageService.saveTasks() persists data to disk (encrypted)
8. SwiftUI automatically updates TasksView with new task
```

## Security & Privacy

### Data Encryption

- All data files are encrypted before writing to disk
- Encryption keys are stored in macOS Keychain
- Uses Security framework for Keychain operations
- XOR encryption for demonstration (use CryptoKit in production)

### Storage Location

- Data stored in user's Documents directory
- Files: `tasks.json`, `scheduleEvents.json`, `reminders.json`
- All files are encrypted

### Notifications

- Uses macOS UserNotifications framework
- Requests authorization on first launch
- Respects user's system notification settings

## Testing

### Unit Tests

Located in `Tests/` directory:

- **TaskTests.swift**: Tests for model objects
- **StorageServiceTests.swift**: Tests for data persistence

### Running Tests

```bash
# Command line
swift test

# Xcode
Cmd+U
```

### Test Coverage Areas

- Model creation and properties
- Task completion toggling
- Priority colors
- Data persistence (save/load)
- Keychain operations

## Building and Running

### Debug Build

```bash
swift build
swift run
```

### Release Build

```bash
swift build -c release
.build/release/SideAiMacApp
```

### Code Signing (for distribution)

For distribution, you'll need to:
1. Enroll in Apple Developer Program
2. Create signing certificates
3. Configure entitlements (notifications, calendar access)
4. Notarize the app

## Future Enhancements

Potential areas for improvement:

1. **Calendar Integration**: Sync with macOS Calendar app
2. **iCloud Sync**: Optional cloud backup
3. **Widgets**: Today widget for quick task access
4. **Siri Integration**: Voice commands for tasks
5. **Menu Bar App**: Quick access from menu bar
6. **Export/Import**: Data portability
7. **Themes**: Custom color schemes
8. **Drag & Drop**: Reorder tasks and events
9. **Tags**: Enhanced tag management
10. **Statistics**: Productivity analytics

## Troubleshooting

### Build Issues

**Problem**: "No such module 'SwiftUI'"
**Solution**: Ensure you're building on macOS, not Linux

**Problem**: Notification permissions not working
**Solution**: Check System Settings → Notifications → SideAi

**Problem**: Data not persisting
**Solution**: Check file permissions in Documents directory

### Performance

- Use Instruments (Time Profiler) for performance analysis
- SwiftUI Previews for rapid UI iteration
- Memory leaks: Use Memory Graph Debugger

## Contributing

When contributing to this project:

1. Follow Swift naming conventions
2. Add tests for new features
3. Update documentation
4. Use SwiftUI best practices
5. Consider accessibility (VoiceOver, Dynamic Type)

## Resources

- [Swift.org](https://swift.org)
- [SwiftUI Documentation](https://developer.apple.com/xcode/swiftui/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/macos)
- [Swift Package Manager](https://swift.org/package-manager/)

## License

See LICENSE.md in the repository root.
