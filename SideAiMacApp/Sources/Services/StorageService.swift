import Foundation
import Security

class StorageService {
    private let tasksKey = "sideai.tasks"
    private let scheduleEventsKey = "sideai.scheduleEvents"
    private let remindersKey = "sideai.reminders"
    private let keychainService = "com.sideai.macapp"
    
    private var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    // MARK: - Task Storage
    
    func saveTasks(_ tasks: [Task]) {
        saveToFile(tasks, filename: "tasks.json")
    }
    
    func loadTasks() -> [Task] {
        loadFromFile("tasks.json") ?? []
    }
    
    // MARK: - Schedule Event Storage
    
    func saveScheduleEvents(_ events: [ScheduleEvent]) {
        saveToFile(events, filename: "scheduleEvents.json")
    }
    
    func loadScheduleEvents() -> [ScheduleEvent] {
        loadFromFile("scheduleEvents.json") ?? []
    }
    
    // MARK: - Reminder Storage
    
    func saveReminders(_ reminders: [Reminder]) {
        saveToFile(reminders, filename: "reminders.json")
    }
    
    func loadReminders() -> [Reminder] {
        loadFromFile("reminders.json") ?? []
    }
    
    // MARK: - Generic File Operations (Encrypted)
    
    private func saveToFile<T: Encodable>(_ data: T, filename: String) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let jsonData = try encoder.encode(data)
            
            // Encrypt data before saving
            let encryptedData = try encryptData(jsonData, key: filename)
            
            let fileURL = documentsDirectory.appendingPathComponent(filename)
            try encryptedData.write(to: fileURL, options: [.atomic])
        } catch {
            print("Error saving \(filename): \(error)")
        }
    }
    
    private func loadFromFile<T: Decodable>(_ filename: String) -> T? {
        do {
            let fileURL = documentsDirectory.appendingPathComponent(filename)
            guard FileManager.default.fileExists(atPath: fileURL.path) else {
                return nil
            }
            
            let encryptedData = try Data(contentsOf: fileURL)
            
            // Decrypt data before loading
            let jsonData = try decryptData(encryptedData, key: filename)
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(T.self, from: jsonData)
        } catch {
            print("Error loading \(filename): \(error)")
            return nil
        }
    }
    
    // MARK: - Keychain Operations
    
    func saveToKeychain(key: String, value: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        
        // Delete any existing item
        deleteFromKeychain(key: key)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    func loadFromKeychain(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return value
    }
    
    func deleteFromKeychain(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
    
    // MARK: - Encryption Helpers
    
    private func encryptData(_ data: Data, key: String) throws -> Data {
        // Get or create encryption key from keychain
        let encryptionKey = getOrCreateEncryptionKey(for: key)
        
        // Simple XOR encryption (for demonstration - use proper encryption in production)
        var encrypted = Data()
        let keyData = encryptionKey.data(using: .utf8) ?? Data()
        
        for (index, byte) in data.enumerated() {
            let keyByte = keyData[index % keyData.count]
            encrypted.append(byte ^ keyByte)
        }
        
        return encrypted
    }
    
    private func decryptData(_ data: Data, key: String) throws -> Data {
        // Get encryption key from keychain
        guard let encryptionKey = loadFromKeychain(key: "encryption-\(key)") else {
            throw StorageError.keyNotFound
        }
        
        // Simple XOR decryption (for demonstration - use proper encryption in production)
        var decrypted = Data()
        let keyData = encryptionKey.data(using: .utf8) ?? Data()
        
        for (index, byte) in data.enumerated() {
            let keyByte = keyData[index % keyData.count]
            decrypted.append(byte ^ keyByte)
        }
        
        return decrypted
    }
    
    private func getOrCreateEncryptionKey(for identifier: String) -> String {
        let keychainKey = "encryption-\(identifier)"
        
        if let existingKey = loadFromKeychain(key: keychainKey) {
            return existingKey
        }
        
        // Create new key
        let newKey = UUID().uuidString
        _ = saveToKeychain(key: keychainKey, value: newKey)
        return newKey
    }
    
    enum StorageError: Error {
        case keyNotFound
        case encryptionFailed
        case decryptionFailed
    }
}
