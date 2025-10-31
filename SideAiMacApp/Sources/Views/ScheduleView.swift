import SwiftUI

struct ScheduleView: View {
    @EnvironmentObject var taskManager: TaskManager
    @State private var showingAddEvent = false
    @State private var selectedEvent: ScheduleEvent?
    @State private var selectedDate = Date()
    
    var eventsForSelectedDate: [ScheduleEvent] {
        taskManager.scheduleEvents.filter { event in
            Calendar.current.isDate(event.startDate, inSameDayAs: selectedDate)
        }.sorted { $0.startDate < $1.startDate }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Schedule")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: { showingAddEvent = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
                .buttonStyle(.borderless)
            }
            .padding()
            
            // Calendar and events
            HStack(spacing: 0) {
                // Calendar picker
                VStack {
                    DatePicker(
                        "",
                        selection: $selectedDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                    .padding()
                    
                    Spacer()
                }
                .frame(width: 300)
                .background(Color(NSColor.controlBackgroundColor))
                
                Divider()
                
                // Events list for selected date
                VStack(alignment: .leading, spacing: 0) {
                    Text(formatDateHeader(selectedDate))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding()
                    
                    Divider()
                    
                    if eventsForSelectedDate.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "calendar.badge.exclamationmark")
                                .font(.system(size: 50))
                                .foregroundColor(.secondary)
                            Text("No events scheduled")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("Tap + to add an event")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List {
                            ForEach(eventsForSelectedDate) { event in
                                EventRowView(event: event, onTap: {
                                    selectedEvent = event
                                })
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        taskManager.deleteScheduleEvent(event)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .listStyle(.plain)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .sheet(isPresented: $showingAddEvent) {
            AddEventView(initialDate: selectedDate)
        }
        .sheet(item: $selectedEvent) { event in
            EventDetailView(event: event)
        }
    }
    
    private func formatDateHeader(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: date)
    }
}

struct EventRowView: View {
    let event: ScheduleEvent
    let onTap: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Time indicator
            VStack(alignment: .leading, spacing: 2) {
                Text(formatTime(event.startDate))
                    .font(.caption)
                    .fontWeight(.semibold)
                if !event.isAllDay {
                    Text(formatTime(event.endDate))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 60, alignment: .leading)
            
            // Event color bar
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.accentColor)
                .frame(width: 4)
            
            // Event content
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                
                if !event.description.isEmpty {
                    Text(event.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                if let location = event.location {
                    Label(location, systemImage: "location")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct AddEventView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var taskManager: TaskManager
    
    let initialDate: Date
    
    @State private var title = ""
    @State private var description = ""
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var location = ""
    @State private var isAllDay = false
    
    init(initialDate: Date) {
        self.initialDate = initialDate
        _startDate = State(initialValue: initialDate)
        _endDate = State(initialValue: initialDate.addingTimeInterval(3600))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Event Details") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Location") {
                    TextField("Location (optional)", text: $location)
                }
                
                Section("Time") {
                    Toggle("All Day", isOn: $isAllDay)
                    
                    DatePicker(
                        "Starts",
                        selection: $startDate,
                        displayedComponents: isAllDay ? [.date] : [.date, .hourAndMinute]
                    )
                    
                    DatePicker(
                        "Ends",
                        selection: $endDate,
                        displayedComponents: isAllDay ? [.date] : [.date, .hourAndMinute]
                    )
                    .onChange(of: startDate) { _, newValue in
                        if endDate < newValue {
                            endDate = newValue.addingTimeInterval(3600)
                        }
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("New Event")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let event = ScheduleEvent(
                            title: title,
                            description: description,
                            startDate: startDate,
                            endDate: endDate,
                            location: location.isEmpty ? nil : location,
                            isAllDay: isAllDay
                        )
                        taskManager.addScheduleEvent(event)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
        .frame(width: 500, height: 600)
    }
}

struct EventDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var taskManager: TaskManager
    
    let event: ScheduleEvent
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    LabeledContent("Title", value: event.title)
                    if !event.description.isEmpty {
                        LabeledContent("Description") {
                            Text(event.description)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section("Time") {
                    if event.isAllDay {
                        LabeledContent("All Day Event", value: "Yes")
                    }
                    LabeledContent("Starts", value: event.startDate, format: .dateTime)
                    LabeledContent("Ends", value: event.endDate, format: .dateTime)
                }
                
                if let location = event.location {
                    Section("Location") {
                        Text(location)
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        taskManager.deleteScheduleEvent(event)
                        dismiss()
                    } label: {
                        Label("Delete Event", systemImage: "trash")
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Event Details")
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
