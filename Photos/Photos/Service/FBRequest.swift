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
    var elements = [Element]()
    private var next: String?
    
    private var cache: Cache<String, FBRequest<Element>>
    
    var hasNext: Bool {
        return next != .none
    }
    
    init(request: GraphRequest, cache: Cache<String, FBRequest<Element>>) {
        self.request = request
        self.cache = cache
    }
    
    func fetch(completion: @escaping (Result<[Element],Error>) -> Void) {
        guard let _ = AccessToken.current else {
            completion(Result.failure(ServiceError.notAuthorised))
            return
        }
        if elements.isEmpty,
           let fbRequest = cache.value(forKey: request.graphPath) {
            self.request = fbRequest.request
            self.elements = fbRequest.elements
            self.next = fbRequest.next
            DispatchQueue.main.async {
                completion(Result.success(self.elements))
            }
            return
        }
        if hasNext {
            let params = Utility.dictionary(withQuery: next!)
            for (key, value) in params {
                request.parameters[key] = value
            }
        }
        request.start { [weak self] connection, result, error in
            if let error = error {
                completion(Result.failure(error))
                return
            }
            guard let result = result else { return }
            DispatchQueue.global(qos: .userInteractive).async {
                if let data = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted) {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    if let fbResult = try? decoder.decode(FBResult<Element>.self, from: data) {
                        self?.next = fbResult.paging.next
                        DispatchQueue.main.async {
                            completion(Result.success(fbResult.data))
                        }
                        self?.elements.append(contentsOf: fbResult.data)
                        self?.cache.insert(self!, forKey: self!.request.graphPath)
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
