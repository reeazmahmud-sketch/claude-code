import XCTest
@testable import SideAiMacApp

final class TaskTests: XCTestCase {
    
    func testTaskCreation() {
        let task = Task(
            title: "Test Task",
            description: "Test Description",
            priority: .high
        )
        
        XCTAssertEqual(task.title, "Test Task")
        XCTAssertEqual(task.description, "Test Description")
        XCTAssertEqual(task.priority, .high)
        XCTAssertFalse(task.isCompleted)
    }
    
    func testTaskToggleCompletion() {
        var task = Task(
            title: "Test Task",
            description: "Test Description"
        )
        
        XCTAssertFalse(task.isCompleted)
        
        task.toggleCompletion()
        XCTAssertTrue(task.isCompleted)
        
        task.toggleCompletion()
        XCTAssertFalse(task.isCompleted)
    }
    
    func testTaskPriorityColors() {
        XCTAssertEqual(Task.Priority.low.color, "blue")
        XCTAssertEqual(Task.Priority.medium.color, "green")
        XCTAssertEqual(Task.Priority.high.color, "orange")
        XCTAssertEqual(Task.Priority.urgent.color, "red")
    }
    
    func testScheduleEventCreation() {
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(3600)
        
        let event = ScheduleEvent(
            title: "Test Event",
            description: "Test Description",
            startDate: startDate,
            endDate: endDate,
            location: "Test Location"
        )
        
        XCTAssertEqual(event.title, "Test Event")
        XCTAssertEqual(event.location, "Test Location")
        XCTAssertFalse(event.isAllDay)
    }
    
    func testReminderCreation() {
        let reminderDate = Date().addingTimeInterval(3600)
        
        let reminder = Reminder(
            title: "Test Reminder",
            notes: "Test Notes",
            reminderDate: reminderDate,
            repeatInterval: .daily
        )
        
        XCTAssertEqual(reminder.title, "Test Reminder")
        XCTAssertEqual(reminder.notes, "Test Notes")
        XCTAssertEqual(reminder.repeatInterval, .daily)
        XCTAssertFalse(reminder.isCompleted)
    }
    
    func testReminderRepeatIntervals() {
        let intervals = Reminder.RepeatInterval.allCases
        XCTAssertEqual(intervals.count, 4)
        XCTAssertTrue(intervals.contains(.none))
        XCTAssertTrue(intervals.contains(.daily))
        XCTAssertTrue(intervals.contains(.weekly))
        XCTAssertTrue(intervals.contains(.monthly))
    }
}
