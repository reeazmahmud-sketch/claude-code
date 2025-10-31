# Security Documentation

## Overview

SideAi implements multiple security measures to protect user data. This document outlines the security architecture, current implementations, and recommendations for production deployment.

## Current Security Implementation

### 1. Data Encryption

**Current Implementation**:
- XOR encryption for demonstration purposes
- Encryption applied before writing to disk
- Decryption applied when reading from disk

**Files Encrypted**:
- `tasks.json` - Task data
- `scheduleEvents.json` - Schedule event data
- `reminders.json` - Reminder data

**Location**: `~/Documents/`

### 2. Keychain Integration

**Purpose**: Secure storage of encryption keys

**Implementation**:
```swift
Service: "com.sideai.macapp"
Account: "encryption-{file-identifier}"
Type: Generic Password
Accessibility: When Unlocked
```

**Features**:
- Encryption keys never stored in plain text
- Keys generated per file type
- macOS Keychain protection
- Keys accessible only when device is unlocked

### 3. Access Control

**Data Access**:
- App sandbox restricts file system access
- Data stored in app's Documents container
- No network access required
- No cloud synchronization (local only)

**Permissions Required**:
- File system access (Documents)
- User notifications
- Keychain access (automatic)

## Security Considerations

### Current Limitations

1. **XOR Encryption (Demonstration Only)**
   - ⚠️ **NOT cryptographically secure**
   - Vulnerable to known-plaintext attacks
   - No authentication of encrypted data
   - No protection against tampering

2. **Key Management**
   - Keys stored in Keychain (secure)
   - But used with weak encryption algorithm
   - No key rotation implemented
   - No key derivation function

3. **No Data Integrity Checks**
   - No HMAC or digital signatures
   - Corrupted data may not be detected
   - No protection against tampering

## Production Recommendations

### 1. Implement CryptoKit Encryption

**Replace XOR with AES-GCM**:

```swift
import CryptoKit

func encryptData(_ data: Data, key: String) throws -> Data {
    // Generate or retrieve a proper symmetric key
    let keyData = key.data(using: .utf8)!
    let symmetricKey = SymmetricKey(data: SHA256.hash(data: keyData))
    
    // Encrypt with AES-GCM (provides authentication)
    let sealedBox = try AES.GCM.seal(data, using: symmetricKey)
    
    // Return combined data (nonce + ciphertext + tag)
    return sealedBox.combined!
}

func decryptData(_ data: Data, key: String) throws -> Data {
    // Retrieve symmetric key
    let keyData = key.data(using: .utf8)!
    let symmetricKey = SymmetricKey(data: SHA256.hash(data: keyData))
    
    // Create sealed box from combined data
    let sealedBox = try AES.GCM.SealedBox(combined: data)
    
    // Decrypt and authenticate
    return try AES.GCM.open(sealedBox, using: symmetricKey)
}
```

**Benefits**:
- ✅ Industry-standard encryption (AES-256)
- ✅ Authenticated encryption (GCM mode)
- ✅ Protection against tampering
- ✅ Random nonces for each encryption
- ✅ Apple's native CryptoKit framework

### 2. Implement Key Derivation

**Use PBKDF2 or Argon2**:

```swift
import CryptoKit

func deriveKey(from password: String, salt: Data) -> SymmetricKey {
    let passwordData = password.data(using: .utf8)!
    // Use PBKDF2 with high iteration count
    // Or use Argon2 (via third-party library)
    return SymmetricKey(data: SHA256.hash(data: passwordData))
}
```

### 3. Add Data Integrity Checks

**Implement HMAC**:

```swift
func signData(_ data: Data, key: SymmetricKey) -> Data {
    let signature = HMAC<SHA256>.authenticationCode(for: data, using: key)
    return Data(signature)
}

func verifySignature(_ data: Data, signature: Data, key: SymmetricKey) -> Bool {
    let expectedSignature = HMAC<SHA256>.authenticationCode(for: data, using: key)
    return Data(expectedSignature) == signature
}
```

### 4. Implement Secure Key Generation

```swift
func generateSecureKey() -> SymmetricKey {
    // Generate a random 256-bit key
    return SymmetricKey(size: .bits256)
}

func generateSecureSalt() -> Data {
    // Generate random salt
    var bytes = [UInt8](repeating: 0, count: 16)
    _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
    return Data(bytes)
}
```

### 5. Add Key Rotation

```swift
func rotateEncryptionKey(oldKey: SymmetricKey, newKey: SymmetricKey) throws {
    // 1. Decrypt all data with old key
    // 2. Re-encrypt with new key
    // 3. Update key in Keychain
    // 4. Delete old key securely
}
```

## Security Best Practices

### Application Sandboxing

**Enable App Sandbox**:
- Restricts file system access
- Limits network access
- Protects user privacy
- Required for Mac App Store

**Entitlements Needed**:
```xml
<key>com.apple.security.app-sandbox</key>
<true/>
<key>com.apple.security.files.user-selected.read-write</key>
<true/>
<key>com.apple.security.personal-information.calendars</key>
<true/>
```

### Code Signing

**For Distribution**:
```bash
codesign --force --options runtime --sign "Developer ID Application" SideAiMacApp
```

**Notarization**:
```bash
xcrun notarytool submit SideAiMacApp.zip --wait
xcrun stapler staple SideAiMacApp.app
```

### Secure Coding Practices

1. **Input Validation**
   - Validate all user input
   - Sanitize file paths
   - Limit string lengths

2. **Error Handling**
   - Don't expose sensitive information in errors
   - Log security events appropriately
   - Handle exceptions gracefully

3. **Memory Management**
   - Use Swift's ARC
   - Clear sensitive data from memory
   - Avoid memory leaks

4. **Third-Party Dependencies**
   - Audit all dependencies
   - Keep dependencies updated
   - Use dependency scanning tools

## Threat Model

### Threats Considered

1. **Local File Access**
   - Mitigation: File encryption, Keychain protection
   - Status: ✅ Implemented (needs stronger encryption)

2. **Data Tampering**
   - Mitigation: Authenticated encryption, HMAC
   - Status: ⚠️ Needs implementation

3. **Memory Attacks**
   - Mitigation: Swift memory safety, short data lifetime
   - Status: ✅ Partially protected

4. **Malicious Software**
   - Mitigation: App sandbox, code signing
   - Status: ⚠️ Needs implementation for distribution

### Threats Not Addressed

1. **Device Theft** (unlocked)
   - Data accessible if device is unlocked
   - Recommendation: Use FileVault

2. **Keyloggers**
   - Can capture user input
   - No application-level mitigation

3. **Screen Recording**
   - Sensitive data visible on screen
   - No application-level mitigation

4. **Backup Security**
   - Time Machine backups not encrypted by app
   - Recommendation: Enable FileVault

## Compliance Considerations

### GDPR (if applicable)

- ✅ Data minimization (only essential data)
- ✅ User control (local storage only)
- ✅ Right to erasure (delete function)
- ✅ Data portability (JSON format)
- ⚠️ Encryption at rest (needs improvement)

### Privacy

- ✅ No telemetry or tracking
- ✅ No cloud storage
- ✅ No third-party sharing
- ✅ Clear privacy policy
- ✅ Local-only processing

## Security Checklist for Production

### Before Release

- [ ] Replace XOR encryption with AES-GCM (CryptoKit)
- [ ] Implement key derivation (PBKDF2)
- [ ] Add data integrity checks (HMAC)
- [ ] Implement secure key generation
- [ ] Add key rotation capability
- [ ] Enable App Sandbox
- [ ] Configure entitlements
- [ ] Code signing with valid certificate
- [ ] Notarization for distribution
- [ ] Security audit/penetration testing
- [ ] Privacy policy review
- [ ] Compliance verification

### Ongoing

- [ ] Regular security updates
- [ ] Monitor for vulnerabilities
- [ ] Update dependencies
- [ ] Security incident response plan
- [ ] Regular backups
- [ ] Access control review

## Security Updates

### Version History

**v1.0.0** (Current - Demo)
- XOR encryption (demonstration only)
- Keychain integration
- Local storage
- Basic access controls

**v1.1.0** (Planned - Production)
- AES-GCM encryption
- Key derivation
- Data integrity checks
- App sandboxing
- Code signing

## Reporting Security Issues

If you discover a security vulnerability:

1. **Do not** create a public GitHub issue
2. Email security concerns privately
3. Include:
   - Description of vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

## References

- [Apple CryptoKit Documentation](https://developer.apple.com/documentation/cryptokit)
- [Apple Security Framework](https://developer.apple.com/documentation/security)
- [OWASP Mobile Security](https://owasp.org/www-project-mobile-security/)
- [Apple App Sandbox](https://developer.apple.com/documentation/security/app_sandbox)

## Disclaimer

The current implementation uses XOR encryption for **demonstration purposes only**. It is **NOT suitable for production use** without implementing the recommended security enhancements outlined in this document.

For production deployment, implement proper AES-GCM encryption using Apple's CryptoKit framework as described in the "Production Recommendations" section.
