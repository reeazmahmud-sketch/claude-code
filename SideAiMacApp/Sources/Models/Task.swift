import Foundation

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
    
    enum Priority: String, Codable, CaseIterable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        case urgent = "Urgent"
        
        var color: String {
            switch self {
            case .low: return "blue"
            case .medium: return "green"
            case .high: return "orange"
            case .urgent: return "red"
            }
        }
    }
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String = "",
        dueDate: Date? = nil,
        priority: Priority = .medium,
        isCompleted: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        tags: [String] = [],
        reminderDate: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.dueDate = dueDate
        self.priority = priority
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.tags = tags
        self.reminderDate = reminderDate
    }
    
    mutating func toggleCompletion() {
        isCompleted.toggle()
        updatedAt = Date()
    }
}

struct ScheduleEvent: Identifiable, Codable, Hashable {
    var id: UUID
    var title: String
    var description: String
    var startDate: Date
    var endDate: Date
    var location: String?
    var isAllDay: Bool
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String = "",
        startDate: Date,
        endDate: Date,
        location: String? = nil,
        isAllDay: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.startDate = startDate
        self.endDate = endDate
        self.location = location
        self.isAllDay = isAllDay
        self.createdAt = createdAt
    }
}

struct Reminder: Identifiable, Codable, Hashable {
    var id: UUID
    var title: String
    var notes: String
    var reminderDate: Date
    var isCompleted: Bool
    var repeatInterval: RepeatInterval?
    var createdAt: Date
    
    enum RepeatInterval: String, Codable, CaseIterable {
        case none = "None"
        case daily = "Daily"
        case weekly = "Weekly"
        case monthly = "Monthly"
    }
    
    init(
        id: UUID = UUID(),
        title: String,
        notes: String = "",
        reminderDate: Date,
        isCompleted: Bool = false,
        repeatInterval: RepeatInterval? = .none,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.reminderDate = reminderDate
        self.isCompleted = isCompleted
        self.repeatInterval = repeatInterval
        self.createdAt = createdAt
    }
}
