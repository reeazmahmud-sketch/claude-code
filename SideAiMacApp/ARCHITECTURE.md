# Architecture Documentation

## Overview

SideAi is built using modern Swift development practices, following Apple's recommended patterns and frameworks for macOS application development.

## Technology Stack

### Core Technologies
- **Swift 6.0**: Programming language
- **SwiftUI**: Declarative UI framework
- **Combine**: Reactive programming framework
- **Swift Package Manager**: Dependency management and build system

### Apple Frameworks
- **Foundation**: Core functionality and data types
- **UserNotifications**: macOS notification system
- **Security**: Keychain integration
- **AppKit**: macOS windowing and app lifecycle

## Architecture Pattern: MVVM

```
┌──────────────────────────────────────────────────────────┐
│                         View Layer                        │
│                   (SwiftUI Views)                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │ ContentView  │  │  TasksView   │  │ ScheduleView │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │RemindersView │  │ SettingsView │  │OnboardingView│  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└───────────────────────┬──────────────────────────────────┘
                        │ @EnvironmentObject
                        │ @StateObject
┌───────────────────────▼──────────────────────────────────┐
│                   ViewModel Layer                         │
│                 (State Management)                        │
│  ┌──────────────────────┐  ┌─────────────────────────┐  │
│  │    TaskManager       │  │   SettingsManager       │  │
│  │  @MainActor class    │  │   @MainActor class      │  │
│  │  ObservableObject    │  │   ObservableObject      │  │
│  └──────────────────────┘  └─────────────────────────┘  │
└───────────────────────┬──────────────────────────────────┘
                        │ Uses/Manipulates
┌───────────────────────▼──────────────────────────────────┐
│                      Model Layer                          │
│                   (Data Structures)                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │     Task     │  │ScheduleEvent │  │   Reminder   │  │
│  │    struct    │  │    struct    │  │    struct    │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└───────────────────────┬──────────────────────────────────┘
                        │ Persisted/Loaded by
┌───────────────────────▼──────────────────────────────────┐
│                    Service Layer                          │
│              (Business Logic & I/O)                       │
│  ┌──────────────────────┐  ┌─────────────────────────┐  │
│  │  StorageService      │  │ NotificationManager     │  │
│  │      class           │  │     @MainActor class    │  │
│  └──────────────────────┘  └─────────────────────────┘  │
└──────────────────────────────────────────────────────────┘
```

## Component Breakdown

### 1. View Layer

#### ContentView.swift
- **Role**: Main container and navigation structure
- **Pattern**: NavigationSplitView with sidebar
- **Responsibilities**:
  - Tab/section navigation
  - Environment object injection
  - Onboarding overlay management
  - Window structure

#### TasksView.swift
- **Role**: Task management interface
- **Components**:
  - Task list with filtering
  - Search bar
  - Add/Edit task sheets
  - Task detail modal
  - Swipe actions
- **State**: Uses TaskManager via @EnvironmentObject

#### ScheduleView.swift
- **Role**: Calendar and event interface
- **Components**:
  - Graphical date picker
  - Event list for selected date
  - Add/Edit event sheets
  - Event detail modal
- **Layout**: Split view (calendar left, events right)

#### RemindersView.swift
- **Role**: Reminder management
- **Components**:
  - Reminder list
  - Completion toggles
  - Add/Edit reminder sheets
  - Overdue indicators
- **Features**: Show/hide completed toggle

#### SettingsView.swift
- **Role**: Application settings
- **Structure**: Tabbed interface
- **Tabs**:
  1. General settings
  2. Notification preferences
  3. Appearance options
  4. Advanced/data management

#### OnboardingView.swift
- **Role**: First-time user experience
- **Structure**: 4-page TabView
- **Pages**:
  1. Welcome
  2. Features overview
  3. Notification permissions
  4. Get started tips

### 2. ViewModel Layer

#### TaskManager
```swift
@MainActor
class TaskManager: ObservableObject {
    @Published var tasks: [Task]
    @Published var scheduleEvents: [ScheduleEvent]
    @Published var reminders: [Reminder]
    
    // CRUD operations for all types
    // Notification integration
    // Data persistence coordination
}
```

**Responsibilities**:
- Centralized state management
- Business logic for CRUD operations
- Notification scheduling coordination
- Data persistence coordination
- Thread safety (@MainActor)

**Key Methods**:
- `addTask(_:)`, `updateTask(_:)`, `deleteTask(_:)`, `toggleTaskCompletion(_:)`
- `addScheduleEvent(_:)`, `updateScheduleEvent(_:)`, `deleteScheduleEvent(_:)`
- `addReminder(_:)`, `updateReminder(_:)`, `deleteReminder(_:)`, `toggleReminderCompletion(_:)`

#### SettingsManager
```swift
@MainActor
class SettingsManager: ObservableObject {
    @Published var isFirstLaunch: Bool
    @Published var showOnboarding: Bool
    @Published var theme: Theme
    @Published var notificationsEnabled: Bool
    // ... other settings
}
```

**Responsibilities**:
- User preferences management
- First-launch detection
- Settings persistence via UserDefaults
- Theme management

### 3. Model Layer

#### Task
```swift
struct Task: Identifiable, Codable, Hashable {
    var id: UUID
    var title: String
    var description: String
    var dueDate: Date?
    var priority: Priority
    var isCompleted: Bool
    var createdAt: Date
    var updatedAt: Date
    var tags: [String]
    var reminderDate: Date?
}
```

**Design Principles**:
- Immutable value type (struct)
- Identifiable for SwiftUI lists
- Codable for persistence
- Hashable for Set operations

#### ScheduleEvent
```swift
struct ScheduleEvent: Identifiable, Codable, Hashable {
    var id: UUID
    var title: String
    var description: String
    var startDate: Date
    var endDate: Date
    var location: String?
    var isAllDay: Bool
    var createdAt: Date
}
```

#### Reminder
```swift
struct Reminder: Identifiable, Codable, Hashable {
    var id: UUID
    var title: String
    var notes: String
    var reminderDate: Date
    var isCompleted: Bool
    var repeatInterval: RepeatInterval?
    var createdAt: Date
}
```

### 4. Service Layer

#### StorageService
```swift
class StorageService {
    // File-based persistence
    func saveTasks(_ tasks: [Task])
    func loadTasks() -> [Task]
    
    // Similar for events and reminders
    
    // Keychain operations
    func saveToKeychain(key: String, value: String) -> Bool
    func loadFromKeychain(key: String) -> String?
    
    // Encryption
    private func encryptData(_ data: Data, key: String) -> Data
    private func decryptData(_ data: Data, key: String) -> Data
}
```

**Storage Strategy**:
- JSON files in Documents directory
- Encryption before writing
- Decryption after reading
- Keychain for encryption keys
- ISO8601 date encoding

**File Structure**:
```
~/Documents/
├── tasks.json (encrypted)
├── scheduleEvents.json (encrypted)
└── reminders.json (encrypted)
```

#### NotificationManager
```swift
@MainActor
class NotificationManager: ObservableObject {
    @Published var isAuthorized: Bool
    
    static func requestAuthorization()
    static func scheduleNotification(id: String, title: String, ...)
    static func cancelNotification(id: String)
    static func setBadgeCount(_ count: Int)
}
```

**Notification Strategy**:
- UNUserNotificationCenter integration
- Permission management
- Scheduled notifications
- Badge count updates

## Data Flow Examples

### Creating a Task

```
1. User Action (View)
   ↓
   AddTaskView: User fills form and taps "Add"
   ↓
2. View Model Update
   ↓
   TaskManager.addTask(task)
   ↓
3. State Update
   ↓
   tasks.append(task) → @Published triggers update
   ↓
4. Notification Scheduling
   ↓
   NotificationManager.scheduleNotification(...)
   ↓
5. Persistence
   ↓
   StorageService.saveTasks(tasks)
   ↓
6. Encryption & Storage
   ↓
   Encrypt → Write to disk
   ↓
7. UI Update (Automatic)
   ↓
   SwiftUI updates TasksView (reactive)
```

### Loading Data on Launch

```
1. App Launch
   ↓
   TaskManager.init()
   ↓
2. Load Data
   ↓
   loadData() called in init
   ↓
3. Storage Service
   ↓
   tasks = storageService.loadTasks()
   ↓
4. File Reading
   ↓
   Read encrypted file from disk
   ↓
5. Decryption
   ↓
   Get key from Keychain → Decrypt
   ↓
6. Deserialization
   ↓
   JSON decode to [Task]
   ↓
7. State Update
   ↓
   @Published tasks updated
   ↓
8. UI Render
   ↓
   SwiftUI renders TasksView with data
```

## State Management

### Observable Objects
- **TaskManager**: Single source of truth for app data
- **SettingsManager**: Single source of truth for settings
- **NotificationManager**: Notification state

### Property Wrappers
- `@Published`: Triggers view updates on change
- `@StateObject`: Lifecycle-tied object ownership
- `@EnvironmentObject`: Shared objects across view hierarchy
- `@State`: View-local state
- `@Binding`: Two-way binding for child views

### Example Flow
```swift
// App entry point
@StateObject private var taskManager = TaskManager()

// Inject into view hierarchy
ContentView()
    .environmentObject(taskManager)

// Access in any child view
@EnvironmentObject var taskManager: TaskManager
```

## Thread Safety

### @MainActor
- All ViewModels marked with `@MainActor`
- Ensures UI updates on main thread
- Prevents data races

### Async/Await
- Future enhancement for async operations
- Currently using completion handlers

## Security Architecture

### Encryption Flow
```
Plain Data → Encryption Key (from Keychain) → XOR Encryption → Disk
```

### Keychain Usage
```swift
Service: "com.sideai.macapp"
Account: "encryption-{file-identifier}"
Type: Generic Password
Accessibility: When Unlocked
```

### Security Considerations
- Encryption keys never leave Keychain
- Data encrypted before writing
- XOR encryption (demo) - use CryptoKit in production
- No network transmission
- No cloud storage

## Testing Strategy

### Unit Tests
- Model object creation and behavior
- Storage service operations
- Keychain integration
- Data serialization/deserialization

### Test Coverage
```
Tests/
├── TaskTests.swift
│   ├── testTaskCreation
│   ├── testTaskToggleCompletion
│   ├── testTaskPriorityColors
│   ├── testScheduleEventCreation
│   └── testReminderCreation
│
└── StorageServiceTests.swift
    ├── testSaveAndLoadTasks
    ├── testSaveAndLoadScheduleEvents
    ├── testSaveAndLoadReminders
    ├── testKeychainSaveAndLoad
    └── testKeychainDelete
```

## Build System

### Swift Package Manager
```swift
// Package.swift
Package(
    name: "SideAiMacApp",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "SideAiMacApp", targets: ["SideAiMacApp"])
    ],
    targets: [
        .executableTarget(name: "SideAiMacApp"),
        .testTarget(name: "SideAiMacAppTests")
    ]
)
```

### Build Process
```
swift build
    ↓
Parse Package.swift
    ↓
Resolve Dependencies (none currently)
    ↓
Compile Swift Sources
    ↓
Link Executable
    ↓
Generate .build/debug/SideAiMacApp
```

## Performance Considerations

### Memory Management
- Value types (structs) for models
- Automatic Reference Counting (ARC)
- `@Published` arrays for efficient updates
- No retain cycles

### UI Performance
- SwiftUI's diffing algorithm
- Lazy loading with List
- Efficient state updates
- Minimal view re-renders

### Optimization Opportunities
- Pagination for large datasets
- Background thread for encryption
- Batch save operations
- Incremental loading

## Extension Points

### Adding New Features

1. **New Data Type**:
   - Add model struct in `Models/`
   - Add CRUD methods to TaskManager
   - Add storage methods to StorageService
   - Create view in `Views/`

2. **New Service**:
   - Create service class in `Services/`
   - Inject into ViewModels
   - Use in business logic

3. **New Settings**:
   - Add @Published property to SettingsManager
   - Add UI in SettingsView
   - Save to UserDefaults

## Dependencies

### Current: None
The app is self-contained with no external dependencies.

### Future Potential
- **CryptoKit**: Better encryption
- **CloudKit**: iCloud sync
- **EventKit**: Calendar integration
- **Intents**: Siri shortcuts

## Deployment

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

### Distribution
1. Code signing certificate
2. Provisioning profile
3. Notarization
4. Distribution methods:
   - Direct download
   - Mac App Store
   - Homebrew cask

## Monitoring & Debugging

### Debugging Tools
- Xcode debugger
- LLDB console
- SwiftUI Previews
- Instruments (Time Profiler, Memory Graph)

### Logging
- Console.app for system logs
- Print statements in debug builds
- NSLog for production logging

## Best Practices Followed

1. **SOLID Principles**
   - Single Responsibility
   - Open/Closed
   - Liskov Substitution
   - Interface Segregation
   - Dependency Inversion

2. **SwiftUI Best Practices**
   - Small, focused views
   - Proper state management
   - Environment object injection
   - View composition

3. **Swift Best Practices**
   - Value types for models
   - Protocol-oriented design
   - Safe optionals handling
   - Clear naming conventions

4. **Security Best Practices**
   - Keychain for secrets
   - Encrypted storage
   - No hardcoded credentials
   - Principle of least privilege

## Conclusion

SideAi demonstrates modern macOS application architecture using Swift and SwiftUI, following Apple's recommended patterns and best practices. The MVVM architecture provides clear separation of concerns, making the codebase maintainable, testable, and extensible.
