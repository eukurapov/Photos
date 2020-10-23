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
    var paging: Paging
    
    struct Paging: Codable {
        var next: String?
    }
}

enum ServiceError: Error {
    case notAuthorised
    case parsing
    case server
}

class PhotoService {
    
    static let shared = PhotoService()
    
    static let fbPhotoPermission = "user_photos"
    
    var isAuthorised: Bool {
        if let token = AccessToken.current, !token.isExpired {
            return true
        } else {
            return false
        }
    }
    
    func albumsRequest() -> FBRequest<Album>? {
        guard let userId = AccessToken.current?.userID else { return nil }
        let request = GraphRequest(
            graphPath: "/\(userId)/albums",
            parameters: ["fields": "id,name,cover_photo,created_time"]
        )
        return FBRequest<Album>(request: request)
    }
    
    func photosRequestForAlbum(_ album: Album) -> FBRequest<Photo> {
        let request = GraphRequest(
            graphPath: "/\(album.id)/photos",
            parameters: ["fields": "id,name,created_time,place,from,likes.summary(true)"]
        )
        return FBRequest<Photo>(request: request)
    }
    
    func fetchCoverImageForAlbum(_ album: Album, completion: @escaping (Result<UIImage,Error>) -> Void) {
        fetchImageForId(album.id, type: "album", completion: completion)
    }
    
    func fetchImageForPhoto(_ photo: Photo, completion: @escaping (Result<UIImage,Error>) -> Void) {
        fetchImageForId(photo.id, completion: completion)
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
    
}
