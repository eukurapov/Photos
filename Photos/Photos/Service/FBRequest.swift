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
    private var next: String?
    
    var hasNext: Bool {
        return next != .none
    }
    
    init(request: GraphRequest) {
        self.request = request
    }
    
    func fetch(completion: @escaping (Result<[Element],Error>) -> Void) {
        guard let _ = AccessToken.current else {
            completion(Result.failure(ServiceError.notAuthorised))
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
