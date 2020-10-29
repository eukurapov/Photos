//
//  Cache.swift
//  Photos
//
//  Created by Eugene Kurapov on 27.10.2020.
//

import UIKit

final class Cache<Key, Value> where Key: Hashable {
    
    private let wrappedCache = NSCache<WrappedKey, WrappedValue>()
    private let keyTracker = KeyTracker()
    var filename: String?
    
    init(filename: String? = nil, maxValueCount: Int = 1000) {
        self.filename = filename
        wrappedCache.countLimit = maxValueCount
        wrappedCache.delegate = keyTracker
    }
    
    func insert(_ value: Value, forKey key: Key) {
        let wrappedValue = WrappedValue(key: key, value: value)
        wrappedCache.setObject(wrappedValue, forKey: WrappedKey(key))
        keyTracker.keys.insert(key)
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
        let key: Key
        let value: Value

        init(key: Key, value: Value) {
            self.key = key
            self.value = value
        }
    }
}

extension Cache.WrappedValue: Codable where Key: Codable, Value: Codable {}

// tracking cached keys to extract values from cache when saving to file
private extension Cache {
    final class KeyTracker: NSObject, NSCacheDelegate {
        var keys = Set<Key>()
        
        // remove key from storage when it's removed from cache
        func cache(_ cache: NSCache<AnyObject, AnyObject>,
                   willEvictObject object: Any) {
            guard let wrappedValue = object as? WrappedValue else {
                return
            }
            keys.remove(wrappedValue.key)
            if let _ = wrappedValue.value as? UIImage,
               let key = wrappedValue.key as? CustomStringConvertible {
                let folderURLs = FileManager.default.urls(
                    for: .cachesDirectory,
                    in: .userDomainMask
                )
                let path = folderURLs[0].appendingPathComponent("\(key.description).jpg")
                try? FileManager.default.removeItem(at: path)
            }
        }
    }
}

// supportive methods to extract and insert WrappedValues while encoding and decoding
private extension Cache {
    func wrappedValue(forKey key: Key) -> WrappedValue? {
        return wrappedCache.object(forKey: WrappedKey(key))
    }

    func insert(_ wrappedValue: WrappedValue) {
        wrappedCache.setObject(wrappedValue, forKey: WrappedKey(wrappedValue.key))
        keyTracker.keys.insert(wrappedValue.key)
    }
}

extension Cache: Codable where Key: Codable, Value: Codable {
    convenience init(from decoder: Decoder) throws {
        self.init()

        let container = try decoder.singleValueContainer()
        let wrappedValues = try container.decode([WrappedValue].self)
        wrappedValues.forEach(insert)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(keyTracker.keys.compactMap(wrappedValue))
    }
}

extension Cache where Key: Codable, Value: Codable {
    
    func saveToFile() throws {
        guard let filename = filename else { return }
        let folderURLs = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        )
        let fileURL = folderURLs[0].appendingPathComponent(filename + ".cache")
        let data = try JSONEncoder().encode(self)
        try data.write(to: fileURL)
    }
    
    static func loadFromFile(named filename: String) -> Cache<Key,Value>? {
        let folderURLs = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        )
        let fileURL = folderURLs[0].appendingPathComponent(filename + ".cache")
        if let data = try? Data(contentsOf: fileURL) {
            if let cache = try? JSONDecoder().decode(Cache<Key,Value>.self, from: data) {
                cache.filename = filename
                return cache
            }
        }
        return nil
    }
    
}

private let maxImageSize: CGFloat = 800

extension Cache where Key: Codable & CustomStringConvertible, Value: UIImage {

    func insert(_ value: Value, forKey key: Key) {
        let wrappedValue = WrappedValue(key: key, value: value)
        wrappedCache.setObject(wrappedValue, forKey: WrappedKey(key))
        keyTracker.keys.insert(key)
        saveImageToFile(value, named: key.description)
    }
    
    func value(forKey key: Key) -> Value? {
        if let wrappedValue = wrappedCache.object(forKey: WrappedKey(key)) {
            return wrappedValue.value
        } else {
            if let value = loadImageFromFile(named: key.description) {
                let wrappedValue = WrappedValue(key: key, value: value)
                wrappedCache.setObject(wrappedValue, forKey: WrappedKey(key))
                keyTracker.keys.insert(key)
                return value
            }
        }
        return nil
    }

    func removeValue(forKey key: Key) {
        wrappedCache.removeObject(forKey: WrappedKey(key))
        try? FileManager.default.removeItem(at: pathForFileNamed(key.description))
    }
    
    private func saveImageToFile(_ image: UIImage, named name: String) {
        let maxSize = max(image.size.height, image.size.width)
        let scale = maxSize > maxImageSize ? (maxImageSize / maxSize) : 1
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        if let imageToSave = (scale != 1 ? image.resizedToFit(size: size) : image) {
            if let data = imageToSave.jpegData(compressionQuality: 1.0) {
                try? data.write(to: pathForFileNamed(name))
            }
        }
    }
    
    private func loadImageFromFile(named name: String) -> Value? {
        return UIImage(contentsOfFile: pathForFileNamed(name).path) as? Value
    }
    
    private func pathForFileNamed(_ name: String) -> URL {
        let folderURLs = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        )
        return folderURLs[0].appendingPathComponent("\(name).jpg")
    }
    
}

extension UIImage {
    
    func resizedToFit(size: CGSize) -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        let context = CGContext(data: nil,
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: cgImage.bitsPerComponent,
                                bytesPerRow: cgImage.bytesPerRow,
                                space: cgImage.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)!,
                                bitmapInfo: cgImage.bitmapInfo.rawValue)
        context?.interpolationQuality = .high
        context?.draw(cgImage, in: CGRect(origin: .zero, size: size))

        guard let scaledImage = context?.makeImage() else { return nil }

        return UIImage(cgImage: scaledImage)
    }

}
