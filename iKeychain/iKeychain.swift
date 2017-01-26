//
//  iKeychain.swift
//  KeychainExample
//
//  Created by Developer on 1/26/17.
//  Copyright © 2017 Developer. All rights reserved.
//

import Security

public class iKeychain {
    
    // MARK: - Properties
    
    public static let `default` = iKeychain()
    
    
    // MARK: - Initializers
    
    /// :nodoc:
    private init() { }
}


public extension iKeychain {
    
    // MARK: - Getting and Setting Values
    
    /**
     Sets the value of the key. Before setting, the old value is removed. So if you want to delete the key, just set its value to `nil`.
     
     - parameter value: The value for the key. Value's type must conform `NSCoding` protocol. It is implemented by all of the Foundation and most of the UIKit types.
     - parameter key: The key for which to create a record in the keychain.
     
     - throws: The `KeychainError` if something went wrong.
     */
    public func setValue(_ value: Any?, forKey key: String) throws {
        var attributes: [String: NSObject] = [
            (kSecClass as String): kSecClassGenericPassword,
            (kSecAttrAccount as String): key as NSObject
        ]
        
        var status: OSStatus
        
        status = SecItemDelete(attributes as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw iKeychainError(code: Int(status))
        }
        
        // If value is nil, we need just delete the key
        guard let value = value else {
            return
        }
        
        attributes[kSecValueData as String] = NSKeyedArchiver.archivedData(withRootObject: value) as NSObject?
        
        status = SecItemAdd(attributes as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw iKeychainError(code: Int(status))
        }
    }
    
    /**
     Returns the value of the key or `nil`, if the key does not exist.
     
     - parameter key: The key for which to get the value.
     
     - throws: The `KeychainError` if something went wrong.
     
     - returns: The key value.
     */
    public func getValue(forKey key: String) throws -> Any? {
        let attributes: [String: NSObject] = [
            (kSecClass as String): kSecClassGenericPassword,
            (kSecReturnData as String): true as NSObject,
            (kSecMatchLimit as String): kSecMatchLimitOne,
            (kSecAttrAccount as String): key as NSObject
        ]
        
        var result: AnyObject?
        var status: OSStatus
        
        status = SecItemCopyMatching(attributes as CFDictionary, &result)
        guard status != errSecItemNotFound else {
            return nil
        }
        
        guard status == errSecSuccess else {
            throw iKeychainError(code: Int(status))
        }
        
        return NSKeyedUnarchiver.unarchiveObject(with: result as! Data) as Any?
    }
    
    /**
     Saves the `SecKey` object to the keychain. Before saving, the old value is deleted, So, if you want to delete the item, just set its value to `nil`.
     
     - parameter secKey: The `SecKey` object that will be saved.
     - parameter key: The key name for the `SecKey` item.
     
     - throws: The `KeychainError` if something's wrong.
     */
    public func setSecKey(_ secKey: SecKey?, forKey key: String) throws {
        var attributes: [String: AnyObject] = [
            (kSecClass as String): kSecClassKey,
            (kSecAttrApplicationTag as String): key as AnyObject
        ]
        
        var status: OSStatus
        
        status = SecItemDelete(attributes as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw iKeychainError(code: Int(status))
        }
        
        // If secKey is nil, just delete the key
        guard let secKey = secKey else {
            return
        }
        
        attributes[kSecValueRef as String] = secKey
        
        status = SecItemAdd(attributes as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw iKeychainError(code: Int(status))
        }
    }
    
    /**
     Returns the `SecKey` object associated with the key or `nil`, if the key does not exist.
     
     - parameter key: The key for which to get the `SecKey`.
     
     - throws: The `KeychainError` if something's wrong.
     
     - returns: The `SecKey` object.
     */
    public func getSecKey(forKey key: String) throws -> SecKey? {
        let attributes: [String: NSObject] = [
            (kSecClass as String): kSecClassKey,
            (kSecAttrApplicationTag as String): key as NSObject,
            (kSecReturnRef as String): true as NSObject
        ]
        
        var secKey: AnyObject?
        var status: OSStatus
        
        status = SecItemCopyMatching(attributes as CFDictionary, &secKey)
        guard status != errSecItemNotFound else {
            return nil
        }
        
        guard status == errSecSuccess else {
            throw iKeychainError(code: Int(status))
        }
        
        return secKey as! SecKey?
    }
    
    /**
     
     Deletes the single keychain item specified by the key.
     
     - parameter itemKey: The key that is used to delete the keychain item.
     - returns: True if the item was successfully deleted.
     
     */
    public func remove(_ itemKey: String) -> Bool {
        let queryDelete: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: itemKey as AnyObject
        ]
        
        let resultCodeDelete = SecItemDelete(queryDelete as CFDictionary)
        
        if resultCodeDelete != noErr {
            return false
        }
        
        return true
    }
}
