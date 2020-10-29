//
//  PhotoService.swift
//  Photos
//
//  Created by Eugene Kurapov on 14.10.2020.
//

import Foundation
import FBSDKCoreKit

enum ServiceError: Error {
    case notAuthorised
    case parsing
    case server
    case unknown
}

typealias AlbumsCache = Cache<String, FBResult<Album>>
typealias PhotosCache = Cache<String, FBResult<Photo>>

class PhotoService {
    
    static let shared = PhotoService()
    
    static let fbPhotoPermission = "user_photos"
    
    private let albumsCacheFileName = "albums"
    private let photosCacheFileName = "photos"
    
    private let fullScreenPrefix = "fs-"
    
    private lazy var albumsRequestCache: AlbumsCache = AlbumsCache(filename: albumsCacheFileName)
    private lazy var photosRequestCache: PhotosCache = PhotosCache(filename: photosCacheFileName)
    private lazy var imageCache = Cache<String, UIImage>()
    
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
        return FBRequest<Album>(request: request, cache: albumsRequestCache)
    }
    
    func photosRequestForAlbum(_ album: Album) -> FBRequest<Photo> {
        let request = GraphRequest(
            graphPath: "/\(album.id)/photos",
            parameters: ["fields": "id,name,created_time,place,from,likes.summary(true),images"]
        )
        return FBRequest<Photo>(request: request, cache: photosRequestCache)
    }
    
    func fetchCoverImageForAlbum(_ album: Album, completion: @escaping (Result<UIImage,Error>) -> Void) {
        guard let token = AccessToken.current?.tokenString else {
            completion(Result.failure(ServiceError.notAuthorised))
            return
        }
        let path = "https://graph.facebook.com/\(album.id)/picture?type=album&access_token=\(token)"
        DispatchQueue.global(qos: .userInitiated).sync {
            self.fetchImageFrom(path: path, cacheKey: album.id, completion: completion)
        }
    }
    
    func fetchImageForPhoto(_ photo: Photo, completion: @escaping (Result<UIImage,Error>) -> Void) {
        guard let token = AccessToken.current?.tokenString else {
            completion(Result.failure(ServiceError.notAuthorised))
            return
        }
        let path = "https://graph.facebook.com/\(photo.id)/picture?type=normal&access_token=\(token)"
        DispatchQueue.global(qos: .userInitiated).sync {
            self.fetchImageFrom(path: path, cacheKey: photo.id, completion: completion)
        }
    }
    
    func fetchFullSizeImageForPhoto(_ photo: Photo, completion: @escaping (Result<UIImage,Error>) -> Void) {
        guard isAuthorised else {
            completion(Result.failure(ServiceError.notAuthorised))
            return
        }
        if let path = photo.fullSizeImageSource {
            DispatchQueue.global(qos: .userInitiated).sync {
                self.fetchImageFrom(path: path, cacheKey: "\(self.fullScreenPrefix)\(photo.id)", completion: completion)
            }
        } else {
            completion(Result.failure(ServiceError.unknown))
            return
        }
    }
    
    private func fetchImageFrom(path: String, cacheKey: String, completion: @escaping (Result<UIImage,Error>) -> Void) {
        if let url = URL(string: path) {
            if let image = imageCache.value(forKey: cacheKey) {
                DispatchQueue.main.async {
                    completion(Result.success(image))
                }
                return
            }
            let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                if let error = error {
                    if let self = self,
                       cacheKey.hasPrefix(self.fullScreenPrefix),
                       let image = self.imageCache.value(forKey: String(cacheKey.dropFirst(self.fullScreenPrefix.count))) {
                        DispatchQueue.main.async {
                            completion(Result.success(image))
                        }
                        return
                    }
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
                    self?.imageCache.insert(image, forKey: cacheKey)
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
