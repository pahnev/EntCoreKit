import Security
import Foundation

enum KeychainError: Error, Equatable {

    /// The value passed for saving could not be converted correctly.
    case conversionFailure

    /// Tried to look for an item that does not exist in the Keychain.
    case itemNotFound

    /// A read of an item in any format other than Data
    case invalidItemFormat

    case unexpectedError

    /// Any operation result status than errSecSuccess
    case unexpectedStatus(OSStatus)
}

public struct Keychain {
    let service: String

    public init(service: String) {
        self.service = service
    }

    /// Gets a `string` saved to the `Keychain`. If nothing has been saved, returns `nil` value.
    /// - Parameter key: The key of the saved `String`.
    /// - Returns: The saved `String` or `nil`.
    public func getString(_ key: String) throws -> String? {
        let query = makeGetQueryFor(key: key)
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        switch status {
            case errSecSuccess:
                guard let data = result as? Data else {
                    throw KeychainError.unexpectedError
                }
                guard let string = String(data: data, encoding: .utf8) else {
                    throw KeychainError.conversionFailure
                }
                return string
            case errSecItemNotFound:
                return nil
            default:
                throw KeychainError.unexpectedStatus(status)
        }
    }

    /// Saves a string value to the `Keychain`.
    /// - Parameters:
    ///   - value: The value to be saved.
    ///   - key: The key associated with the value for retrieval.
    public func set(_ value: String, key: String) throws {
        guard let _ = try getString(key) else {
            try add(value, key: key)
            return
        }
        try update(value, key: key)
    }

    /// Removes a specific value in the `service`.
    /// - Parameter key: The key of the value to be removed.
    public func remove(_ key: String) throws {
        let query = commonQueryFor()

        // SecItemDelete attempts to perform a delete operation
        // for the item identified by query. The status indicates
        // if the operation succeeded or failed.
        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
    }


    /// Removes all values saved under the defined `service`.
    public func removeAll() throws {
        var query = commonQueryFor()
        query[String(kSecMatchLimit)] = kSecMatchLimitAll

        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    // MARK: - Internal

    func commonQueryFor() -> [String: Any] {
        let query: [String: Any] = [
            String(kSecClass): String(kSecClassGenericPassword),
            String(kSecAttrSynchronizable): kSecAttrSynchronizableAny,
            String(kSecAttrService): service
        ]
        return query
    }

    func makeGetQueryFor(key: String) -> [String: Any] {
        var query = commonQueryFor()
        query[String(kSecMatchLimit)] = kSecMatchLimitOne
        query[String(kSecReturnData)] = kCFBooleanTrue
        query[String(kSecAttrAccount)] = key

        return query
    }

    func add(_ value: String, key: String) throws {
        guard let data = value.data(using: .utf8, allowLossyConversion: false) else {
            throw KeychainError.conversionFailure
        }
        var query = commonQueryFor()
        query[String(kSecValueData)] = data
        query[String(kSecAttrAccount)] = key

        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    func update(_ value: String, key: String) throws {
        guard let data = value.data(using: .utf8, allowLossyConversion: false) else {
            throw KeychainError.conversionFailure
        }

        var query = commonQueryFor()
        query[String(kSecAttrAccount)] = key

        // attributes is passed to SecItemUpdate with
        // kSecValueData as the updated item value
        let attributes: [String: Any] = [
            String(kSecValueData): data
        ]

        // SecItemUpdate attempts to update the item identified
        // by query, overriding the previous value
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

        // errSecItemNotFound is a special status indicating the
        // item to update does not exist. Throw itemNotFound so
        // the client can determine whether or not to handle
        // this as an error
        guard status != errSecItemNotFound else {
            throw KeychainError.itemNotFound
        }

        // Any status other than errSecSuccess indicates the
        // update operation failed.
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
    }

}
