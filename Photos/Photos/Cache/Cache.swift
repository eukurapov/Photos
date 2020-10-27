//
//  Cache.swift
//  Photos
//
//  Created by Eugene Kurapov on 27.10.2020.
//

import Foundation

class Cache<Key, Value> where Key: Hashable {
    
    private let wrappedCache = NSCache<WrappedKey, WrappedValue>()
    
    init(maxValueCount: Int = 100) {
        wrappedCache.countLimit = maxValueCount
    }
    
    func insert(_ value: Value, forKey key: Key) {
        let wrappedValue = WrappedValue(value: value)
        wrappedCache.setObject(wrappedValue, forKey: WrappedKey(key))
    }

    func value(forKey key: Key) -> Value? {
        let wrappedValue = wrappedCache.object(forKey: WrappedKey(key))
        return wrappedValue?.value
    }

    func removeValue(forKey key: Key) {
        wrappedCache.removeObject(forKey: WrappedKey(key))
    }
    
}

// adding subscript
extension Cache {
    
    // set to nil to remove value from cache
    subscript(key: Key) -> Value? {
        get {
            return value(forKey: key)
        }
        set {
            guard let value = newValue else {
                removeValue(forKey: key)
                return
            }
            insert(value, forKey: key)
        }
    }
    
}

// wrapping key to NSObject
private extension Cache {
    class WrappedKey: NSObject {
        let key: Key
        
        init(_ key: Key) { self.key = key }
        
        override var hash: Int { return key.hashValue }
        
        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else {
                return false
            }
            return value.key == key
        }
    }
}

// wrapping value to class
private extension Cache {
    final class WrappedValue {
        let value: Value

        init(value: Value) {
            self.value = value
        }
    }
}
