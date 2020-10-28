//
//  FBRequest.swift
//  Photos
//
//  Created by Eugene Kurapov on 20.10.2020.
//

import Foundation
import FBSDKCoreKit
import FBSDKLoginKit

class FBRequest<Element> where Element: Codable {
    
    var request: GraphRequest
    var result: FBResult<Element>!
    
    private var cache: Cache<String, FBResult<Element>>
    
    var hasNext: Bool {
        return result == nil ? false : result.next != .none
    }
    
    init(request: GraphRequest, cache: Cache<String, FBResult<Element>>) {
        self.request = request
        self.cache = cache
    }
    
    deinit {
        try? cache.saveToFile()
    }
    
    func fetch(completion: @escaping (Result<[Element],Error>) -> Void) {
        guard let _ = AccessToken.current else {
            completion(Result.failure(ServiceError.notAuthorised))
            return
        }
        if result == nil,
           let cacheValue = cache.value(forKey: request.graphPath) {
            self.result = cacheValue
            DispatchQueue.main.async {
                completion(Result.success(self.result.elements))
            }
            return
        }
        if hasNext {
            let params = Utility.dictionary(withQuery: result.next!)
            for (key, value) in params {
                request.parameters[key] = value
            }
        }
        request.start { [weak self] connection, requestResult, error in
            if let error = error {
                if let self = self, self.result == nil, let filename = self.cache.filename {
                    if let cache = Cache<String, FBResult<Element>>.loadFromFile(named: filename) {
                        self.cache = cache
                        if let cacheValue = self.cache.value(forKey: self.request.graphPath) {
                            self.result = cacheValue
                            self.result.next = nil
                            DispatchQueue.main.async {
                                completion(Result.success(self.result.elements))
                            }
                            return
                        }
                    }
                }
                completion(Result.failure(error))
                return
            }
            guard let requestResult = requestResult else { return }
            DispatchQueue.global(qos: .userInteractive).async {
                if let data = try? JSONSerialization.data(withJSONObject: requestResult, options: .prettyPrinted) {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    if let fbResult = try? decoder.decode(FBResult<Element>.self, from: data) {
                        DispatchQueue.main.async {
                            completion(Result.success(fbResult.elements))
                        }
                        if self?.result != nil {
                            self?.result.next = fbResult.next
                            self?.result.elements.append(contentsOf: fbResult.elements)
                        } else {
                            self?.result = fbResult
                        }
                        self?.cache.insert(self!.result, forKey: self!.request.graphPath)
                        try? self?.cache.saveToFile()
                        return
                    }
                }
                DispatchQueue.main.async {
                    completion(Result.failure(ServiceError.parsing))
                }
            }
        }
    }
    
}
