//
//  KeychainStorage.swift
//  KeychainApp
//
//  Created by Kakeru Fukuda on 2021/10/04.
//

import Foundation

protocol Storage {
    func save<T: Codable>(key: String, value: T) throws
    func load<T: Codable>(key: String, type: T.Type) throws -> T
}

struct KeychainStorage: Storage {
    func save<T: Codable>(key: String, value: T) throws {
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(value)
        
        let query: [String: Any] = [
            kSecClass       as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "trcom100@gmail.com",
            kSecAttrLabel   as String: key,
            kSecValueData   as String: encoded,
        ]
        
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        switch status {
        case errSecItemNotFound:
            SecItemAdd(query as CFDictionary, nil)
            
        case errSecSuccess:
            SecItemUpdate(query as CFDictionary, [kSecValueData as String: encoded] as CFDictionary)
            
        default:
            print("error: \(status)")
            throw KeychainError.unhandled(error: status)
        }
    }
    
    func load<T: Codable>(key: String, type: T.Type) throws -> T {
        let query: [String: Any] = [
            kSecClass            as String: kSecClassGenericPassword,
            kSecAttrLabel        as String: key,
            kSecAttrAccount      as String: "trcom100@gmail.com",
            kSecMatchLimit       as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData       as String: true,
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        switch status {
        case errSecItemNotFound:
            throw KeychainError.notfound
            
        case errSecSuccess:
            guard let item = item,
                  let value = item[kSecValueData as String] as? Data else {
                      throw KeychainError.unexpectedPasswordData
                  }
            
            return try JSONDecoder().decode(type, from: value)
            
        default:
            print("error: \(status)")
            throw KeychainError.unhandled(error: status)
        }
    }
}

enum KeychainError: Error {
    case notfound
    case unexpectedPasswordData
    case unhandled(error: OSStatus)
}
