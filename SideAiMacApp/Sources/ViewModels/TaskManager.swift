import Foundation
import Combine

@MainActor
class TaskManager: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var scheduleEvents: [ScheduleEvent] = []
    @Published var reminders: [Reminder] = []
    
    private let storageService: StorageService
    
    init(storageService: StorageService = StorageService()) {
        self.storageService = storageService
        loadData()
    }
    
    // MARK: - Task Management
    
    func addTask(_ task: Task) {
        tasks.append(task)
        saveData()
        
        // Schedule reminder if set
        if let reminderDate = task.reminderDate {
            NotificationManager.scheduleNotification(
                id: task.id.uuidString,
                title: "Task Reminder: \(task.title)",
                body: task.description,
                date: reminderDate
            )
        }
    }
    
    func updateTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            saveData()
            
            // Update notification
            NotificationManager.cancelNotification(id: task.id.uuidString)
            if let reminderDate = task.reminderDate, !task.isCompleted {
                NotificationManager.scheduleNotification(
                    id: task.id.uuidString,
                    title: "Task Reminder: \(task.title)",
                    body: task.description,
                    date: reminderDate
                )
            }
        }
    }
    
    func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
        NotificationManager.cancelNotification(id: task.id.uuidString)
        saveData()
    }
    
    func toggleTaskCompletion(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].toggleCompletion()
            if tasks[index].isCompleted {
                NotificationManager.cancelNotification(id: task.id.uuidString)
            }
            saveData()
        }
    }
    
    // MARK: - Schedule Management
    
    func addScheduleEvent(_ event: ScheduleEvent) {
        scheduleEvents.append(event)
        saveData()
        
        // Schedule notification 15 minutes before
        let notificationDate = event.startDate.addingTimeInterval(-15 * 60)
        if notificationDate > Date() {
            NotificationManager.scheduleNotification(
                id: "event-\(event.id.uuidString)",
                title: "Upcoming Event: \(event.title)",
                body: "Starting at \(formatTime(event.startDate))",
                date: notificationDate
            )
        }
    }
    
    func updateScheduleEvent(_ event: ScheduleEvent) {
        if let index = scheduleEvents.firstIndex(where: { $0.id == event.id }) {
            scheduleEvents[index] = event
            saveData()
            
            // Update notification
            NotificationManager.cancelNotification(id: "event-\(event.id.uuidString)")
            let notificationDate = event.startDate.addingTimeInterval(-15 * 60)
            if notificationDate > Date() {
                NotificationManager.scheduleNotification(
                    id: "event-\(event.id.uuidString)",
                    title: "Upcoming Event: \(event.title)",
                    body: "Starting at \(formatTime(event.startDate))",
                    date: notificationDate
                )
            }
        }
    }
    
    func deleteScheduleEvent(_ event: ScheduleEvent) {
        scheduleEvents.removeAll { $0.id == event.id }
        NotificationManager.cancelNotification(id: "event-\(event.id.uuidString)")
        saveData()
    }
    
    // MARK: - Reminder Management
    
    func addReminder(_ reminder: Reminder) {
        reminders.append(reminder)
        saveData()
        
        // Schedule notification
        NotificationManager.scheduleNotification(
            id: "reminder-\(reminder.id.uuidString)",
            title: reminder.title,
            body: reminder.notes,
            date: reminder.reminderDate
        )
    }
    
    func updateReminder(_ reminder: Reminder) {
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminders[index] = reminder
            saveData()
            
            // Update notification
            NotificationManager.cancelNotification(id: "reminder-\(reminder.id.uuidString)")
            if !reminder.isCompleted {
                NotificationManager.scheduleNotification(
                    id: "reminder-\(reminder.id.uuidString)",
                    title: reminder.title,
                    body: reminder.notes,
                    date: reminder.reminderDate
                )
            }
        }
    }
    
    func deleteReminder(_ reminder: Reminder) {
        reminders.removeAll { $0.id == reminder.id }
        NotificationManager.cancelNotification(id: "reminder-\(reminder.id.uuidString)")
        saveData()
    }
    
    func toggleReminderCompletion(_ reminder: Reminder) {
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminders[index].isCompleted.toggle()
            if reminders[index].isCompleted {
                NotificationManager.cancelNotification(id: "reminder-\(reminder.id.uuidString)")
            }
            saveData()
        }
    }
    
    // MARK: - Data Persistence
    
    private func saveData() {
        storageService.saveTasks(tasks)
        storageService.saveScheduleEvents(scheduleEvents)
        storageService.saveReminders(reminders)
    }
    
    private func loadData() {
        tasks = storageService.loadTasks()
        scheduleEvents = storageService.loadScheduleEvents()
        reminders = storageService.loadReminders()
    }
    
    // MARK: - Helper Methods
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
