import SwiftUI

struct RemindersView: View {
    @EnvironmentObject var taskManager: TaskManager
    @State private var showingAddReminder = false
    @State private var selectedReminder: Reminder?
    @State private var showCompleted = false
    
    var filteredReminders: [Reminder] {
        let reminders = taskManager.reminders
        if showCompleted {
            return reminders.sorted { $0.reminderDate < $1.reminderDate }
        } else {
            return reminders.filter { !$0.isCompleted }.sorted { $0.reminderDate < $1.reminderDate }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Reminders")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                Toggle("Show Completed", isOn: $showCompleted)
                    .toggleStyle(.switch)
                
                Button(action: { showingAddReminder = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
                .buttonStyle(.borderless)
            }
            .padding()
            
            // Reminders list
            if filteredReminders.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "bell.badge")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    Text("No reminders")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    Text("Tap + to create a reminder")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(filteredReminders) { reminder in
                        ReminderRowView(reminder: reminder, onToggle: {
                            taskManager.toggleReminderCompletion(reminder)
                        }, onTap: {
                            selectedReminder = reminder
                        })
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                taskManager.deleteReminder(reminder)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .sheet(isPresented: $showingAddReminder) {
            AddReminderView()
        }
        .sheet(item: $selectedReminder) { reminder in
            ReminderDetailView(reminder: reminder)
        }
    }
}

struct ReminderRowView: View {
    let reminder: Reminder
    let onToggle: () -> Void
    let onTap: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Completion checkbox
            Button(action: onToggle) {
                Image(systemName: reminder.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(reminder.isCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)
            
            // Reminder content
            VStack(alignment: .leading, spacing: 4) {
                Text(reminder.title)
                    .font(.headline)
                    .strikethrough(reminder.isCompleted)
                    .foregroundColor(reminder.isCompleted ? .secondary : .primary)
                
                if !reminder.notes.isEmpty {
                    Text(reminder.notes)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                HStack(spacing: 8) {
                    Label(formatDateTime(reminder.reminderDate), systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(isPast(reminder.reminderDate) && !reminder.isCompleted ? .red : .secondary)
                    
                    if let interval = reminder.repeatInterval, interval != .none {
                        Text(interval.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.accentColor.opacity(0.2))
                            .foregroundColor(.accentColor)
                            .cornerRadius(4)
                    }
                }
            }
            
            Spacer()
            
            if isPast(reminder.reminderDate) && !reminder.isCompleted {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
    
    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func isPast(_ date: Date) -> Bool {
        date < Date()
    }
}

struct AddReminderView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var taskManager: TaskManager
    
    @State private var title = ""
    @State private var notes = ""
    @State private var reminderDate = Date()
    @State private var repeatInterval: Reminder.RepeatInterval = .none
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Reminder Details") {
                    TextField("Title", text: $title)
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("When") {
                    DatePicker(
                        "Remind me at",
                        selection: $reminderDate,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }
                
                Section("Repeat") {
                    Picker("Repeat", selection: $repeatInterval) {
                        ForEach(Reminder.RepeatInterval.allCases, id: \.self) { interval in
                            Text(interval.rawValue).tag(interval)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .formStyle(.grouped)
            .navigationTitle("New Reminder")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let reminder = Reminder(
                            title: title,
                            notes: notes,
                            reminderDate: reminderDate,
                            repeatInterval: repeatInterval
                        )
                        taskManager.addReminder(reminder)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
        .frame(width: 500, height: 500)
    }
}

struct ReminderDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var taskManager: TaskManager
    
    let reminder: Reminder
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    LabeledContent("Title", value: reminder.title)
                    if !reminder.notes.isEmpty {
                        LabeledContent("Notes") {
                            Text(reminder.notes)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section("Status") {
                    LabeledContent("Completed", value: reminder.isCompleted ? "Yes" : "No")
                }
                
                Section("Timing") {
                    LabeledContent("Reminder Date", value: reminder.reminderDate, format: .dateTime)
                    if let interval = reminder.repeatInterval, interval != .none {
                        LabeledContent("Repeat", value: interval.rawValue)
                    }
                }
                
                Section("Metadata") {
                    LabeledContent("Created", value: reminder.createdAt, format: .dateTime)
                }
                
                Section {
                    Button(role: .destructive) {
                        taskManager.deleteReminder(reminder)
                        dismiss()
                    } label: {
                        Label("Delete Reminder", systemImage: "trash")
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Reminder Details")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .frame(width: 500, height: 600)
    }
}
