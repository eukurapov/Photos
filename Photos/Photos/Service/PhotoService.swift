//
//  PhotoService.swift
//  Photos
//
//  Created by Eugene Kurapov on 14.10.2020.
//

import Foundation
import FBSDKCoreKit

struct FBResult<Element>: Codable where Element: Codable {
    var data: [Element]
}

enum ServiceError: Error {
    case notAuthorised
    case parsing
    case server
}

class PhotoService {
    
    static let shared = PhotoService()
    
    static let fbPhotoPermission = "user_photos"
    
    private func fetchRequest<T>(_ request: GraphRequest, completion: @escaping (Result<[T],Error>) -> Void) where T: Codable {
        request.start { connection, result, error in
            if let error = error {
                completion(Result.failure(error))
                return
            }
            guard let result = result else { return }
            DispatchQueue.global(qos: .userInteractive).async {
                if let data = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted) {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    if let fbResult = try? decoder.decode(FBResult<T>.self, from: data) {
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
    
    private func fetchImageForId(_ id: String, type: String = "normal", completion: @escaping (Result<UIImage,Error>) -> Void) {
        guard let token = AccessToken.current?.tokenString else {
            completion(Result.failure(ServiceError.notAuthorised))
            return
        }
        let path = "https://graph.facebook.com/\(id)/picture?type=\(type)&access_token=\(token)"
        if let url = URL(string: path) {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    DispatchQueue.main.async {
                        completion(Result.failure(error))
                    }
                    return
                }
                guard let response = response as? HTTPURLResponse,
                      (200...299).contains(response.statusCode) else {
                    DispatchQueue.main.async {
                        completion(Result.failure(ServiceError.server))
                    }
                    return
                }
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        completion(Result.success(image))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(Result.failure(ServiceError.parsing))
                    }
                }
            }
            task.resume()
        }
    }
    
    /**
     Fetching albums from Facebook.
     - Parameter completion: Completion handler running in main thread.
    */
    func fetchAlbums(completion: @escaping (Result<[Album],Error>) -> Void) {
        guard let userId = AccessToken.current?.userID else {
            completion(Result.failure(ServiceError.notAuthorised))
            return
        }
        let request = GraphRequest(
            graphPath: "/\(userId)/albums",
            parameters: ["fields": "id,name,cover_photo,created_time"]
        )
        fetchRequest(request, completion: completion)
    }
    
    /**
     Fetching photos from selected album from Facebook.
     - Parameter completion: Completion handler running in main thread.
    */
    func fetchPhotosForAlbum(_ album: Album, completion: @escaping (Result<[Photo],Error>) -> Void) {
        guard let _ = AccessToken.current else {
            completion(Result.failure(ServiceError.notAuthorised))
            return
        }
        let request = GraphRequest(
            graphPath: "/\(album.id)/photos",
            parameters: ["fields": "id,name,created_time"]
        )
        fetchRequest(request, completion: completion)
    }
    
    func fetchCoverImageForAlbum(_ album: Album, completion: @escaping (Result<UIImage,Error>) -> Void) {
        fetchImageForId(album.id, type: "album", completion: completion)
    }
    
    func fetchAlbumImageForPhoto(_ photo: Photo, completion: @escaping (Result<UIImage,Error>) -> Void) {
        fetchImageForId(photo.id, completion: completion)
    }
    
    private func sendResultToMainQueue<T>(_ result: Result<T,Error>, completion: @escaping (Result<T,Error>) -> Void) {
        DispatchQueue.main.async {
            completion(result)
        }
    }
    
}
