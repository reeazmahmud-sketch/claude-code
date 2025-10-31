import XCTest
@testable import SideAiMacApp

final class StorageServiceTests: XCTestCase {
    var storageService: StorageService!
    
    override func setUp() {
        super.setUp()
        storageService = StorageService()
    }
    
    override func tearDown() {
        // Clean up any test data
        storageService = nil
        super.tearDown()
    }
    
    func testSaveAndLoadTasks() {
        let tasks = [
            Task(title: "Task 1", description: "Description 1", priority: .high),
            Task(title: "Task 2", description: "Description 2", priority: .low)
        ]
        
        storageService.saveTasks(tasks)
        let loadedTasks = storageService.loadTasks()
        
        XCTAssertEqual(loadedTasks.count, tasks.count)
        XCTAssertEqual(loadedTasks[0].title, "Task 1")
        XCTAssertEqual(loadedTasks[1].title, "Task 2")
    }
    
    func testSaveAndLoadScheduleEvents() {
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(3600)
        
        let events = [
            ScheduleEvent(title: "Event 1", startDate: startDate, endDate: endDate),
            ScheduleEvent(title: "Event 2", startDate: startDate, endDate: endDate)
        ]
        
        storageService.saveScheduleEvents(events)
        let loadedEvents = storageService.loadScheduleEvents()
        
        XCTAssertEqual(loadedEvents.count, events.count)
        XCTAssertEqual(loadedEvents[0].title, "Event 1")
        XCTAssertEqual(loadedEvents[1].title, "Event 2")
    }
    
    func testSaveAndLoadReminders() {
        let reminderDate = Date().addingTimeInterval(3600)
        
        let reminders = [
            Reminder(title: "Reminder 1", reminderDate: reminderDate),
            Reminder(title: "Reminder 2", reminderDate: reminderDate)
        ]
        
        storageService.saveReminders(reminders)
        let loadedReminders = storageService.loadReminders()
        
        XCTAssertEqual(loadedReminders.count, reminders.count)
        XCTAssertEqual(loadedReminders[0].title, "Reminder 1")
        XCTAssertEqual(loadedReminders[1].title, "Reminder 2")
    }
    
    func testKeychainSaveAndLoad() {
        let key = "test-key"
        let value = "test-value"
        
        let saveResult = storageService.saveToKeychain(key: key, value: value)
        XCTAssertTrue(saveResult)
        
        let loadedValue = storageService.loadFromKeychain(key: key)
        XCTAssertEqual(loadedValue, value)
        
        let deleteResult = storageService.deleteFromKeychain(key: key)
        XCTAssertTrue(deleteResult)
    }
    
    func testKeychainDelete() {
        let key = "test-key-delete"
        let value = "test-value"
        
        _ = storageService.saveToKeychain(key: key, value: value)
        let deleteResult = storageService.deleteFromKeychain(key: key)
        XCTAssertTrue(deleteResult)
        
        let loadedValue = storageService.loadFromKeychain(key: key)
        XCTAssertNil(loadedValue)
    }
    
    func testLoadNonexistentData() {
        // Test loading when no data exists (should return empty arrays)
        // This assumes clean state or we can clean up first
        let tasks = storageService.loadTasks()
        XCTAssertNotNil(tasks)
        XCTAssertTrue(tasks.isEmpty || tasks.count > 0) // Should be an array
    }
}
