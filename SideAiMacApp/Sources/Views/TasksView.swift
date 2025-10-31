import SwiftUI

struct TasksView: View {
    @EnvironmentObject var taskManager: TaskManager
    @EnvironmentObject var settingsManager: SettingsManager
    @State private var showingAddTask = false
    @State private var selectedTask: Task?
    @State private var searchText = ""
    @State private var filterPriority: Task.Priority?
    
    var filteredTasks: [Task] {
        var tasks = taskManager.tasks
        
        // Filter by completion status
        if !settingsManager.showCompletedTasks {
            tasks = tasks.filter { !$0.isCompleted }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            tasks = tasks.filter { task in
                task.title.localizedCaseInsensitiveContains(searchText) ||
                task.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Filter by priority
        if let priority = filterPriority {
            tasks = tasks.filter { $0.priority == priority }
        }
        
        return tasks.sorted { $0.createdAt > $1.createdAt }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Tasks")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                // Filter by priority
                Menu {
                    Button("All Priorities") {
                        filterPriority = nil
                    }
                    Divider()
                    ForEach(Task.Priority.allCases, id: \.self) { priority in
                        Button(priority.rawValue) {
                            filterPriority = priority
                        }
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .font(.title2)
                }
                .menuStyle(.borderlessButton)
                
                Button(action: { showingAddTask = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
                .buttonStyle(.borderless)
            }
            .padding()
            
            // Search bar
            TextField("Search tasks...", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
                .padding(.bottom)
            
            // Task list
            if filteredTasks.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "checklist")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    Text("No tasks yet")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    Text("Tap + to create your first task")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(filteredTasks) { task in
                        TaskRowView(task: task, onToggle: {
                            taskManager.toggleTaskCompletion(task)
                        }, onTap: {
                            selectedTask = task
                        })
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                taskManager.deleteTask(task)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .sheet(isPresented: $showingAddTask) {
            AddTaskView()
        }
        .sheet(item: $selectedTask) { task in
            TaskDetailView(task: task)
        }
    }
}

struct TaskRowView: View {
    let task: Task
    let onToggle: () -> Void
    let onTap: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Completion checkbox
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(task.isCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)
            
            // Task content
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)
                    .strikethrough(task.isCompleted)
                    .foregroundColor(task.isCompleted ? .secondary : .primary)
                
                if !task.description.isEmpty {
                    Text(task.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                HStack(spacing: 8) {
                    // Priority badge
                    Text(task.priority.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color(task.priority.color).opacity(0.2))
                        .foregroundColor(Color(task.priority.color))
                        .cornerRadius(4)
                    
                    // Due date
                    if let dueDate = task.dueDate {
                        Label(formatDate(dueDate), systemImage: "calendar")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct AddTaskView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var taskManager: TaskManager
    @EnvironmentObject var settingsManager: SettingsManager
    
    @State private var title = ""
    @State private var description = ""
    @State private var priority: Task.Priority
    @State private var dueDate = Date()
    @State private var hasDueDate = false
    @State private var reminderDate = Date()
    @State private var hasReminder = false
    
    init() {
        _priority = State(initialValue: .medium)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Task Details") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Priority") {
                    Picker("Priority", selection: $priority) {
                        ForEach(Task.Priority.allCases, id: \.self) { priority in
                            Text(priority.rawValue).tag(priority)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Due Date") {
                    Toggle("Set Due Date", isOn: $hasDueDate)
                    if hasDueDate {
                        DatePicker("Date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                    }
                }
                
                Section("Reminder") {
                    Toggle("Set Reminder", isOn: $hasReminder)
                    if hasReminder {
                        DatePicker("Remind me at", selection: $reminderDate, displayedComponents: [.date, .hourAndMinute])
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("New Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let task = Task(
                            title: title,
                            description: description,
                            dueDate: hasDueDate ? dueDate : nil,
                            priority: priority,
                            reminderDate: hasReminder ? reminderDate : nil
                        )
                        taskManager.addTask(task)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
        .frame(width: 500, height: 600)
    }
}

struct TaskDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var taskManager: TaskManager
    
    @State var task: Task
    @State private var isEditing = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    if isEditing {
                        TextField("Title", text: $task.title)
                        TextField("Description", text: $task.description, axis: .vertical)
                            .lineLimit(3...6)
                    } else {
                        Text(task.title)
                            .font(.headline)
                        if !task.description.isEmpty {
                            Text(task.description)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section("Status") {
                    Toggle("Completed", isOn: $task.isCompleted)
                        .onChange(of: task.isCompleted) { _, _ in
                            if !isEditing {
                                taskManager.toggleTaskCompletion(task)
                            }
                        }
                }
                
                Section("Priority") {
                    if isEditing {
                        Picker("Priority", selection: $task.priority) {
                            ForEach(Task.Priority.allCases, id: \.self) { priority in
                                Text(priority.rawValue).tag(priority)
                            }
                        }
                        .pickerStyle(.segmented)
                    } else {
                        Text(task.priority.rawValue)
                    }
                }
                
                Section("Dates") {
                    if let dueDate = task.dueDate {
                        LabeledContent("Due Date", value: dueDate, format: .dateTime)
                    }
                    LabeledContent("Created", value: task.createdAt, format: .dateTime)
                    LabeledContent("Updated", value: task.updatedAt, format: .dateTime)
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Task Details")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    if isEditing {
                        Button("Done") {
                            taskManager.updateTask(task)
                            isEditing = false
                        }
                    } else {
                        Button("Edit") {
                            isEditing = true
                        }
                    }
                }
            }
        }
        .frame(width: 500, height: 600)
    }
}
