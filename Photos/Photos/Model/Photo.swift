//
//  Photo.swift
//  Photos
//
//  Created by Eugene Kurapov on 12.10.2020.
//

import Foundation

struct Photo: Codable, Equatable {
        
    var id: String
    var name: String?
    var createdAt: Date
    var place: Place?
    var likes: Likes?
    var images: [Image]?
    
    var fullSizeImageSource: String? {
        return images?[0].source
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case createdAt = "created_time"
        case place
        case likes
        case images
    }
    
    static func == (lhs: Photo, rhs: Photo) -> Bool {
        return lhs.id == rhs.id
    }
    
    struct Place: Codable {
        var name: String
        var location: Location?
        
        struct Location: Codable {
            var country: String?
            var city: String?
            var latitude: Double
            var longitude: Double
        }
    }
    
    struct Likes: Codable {
        var summary: Summary
        
        struct Summary: Codable {
            var total: Int
            
            enum CodingKeys: String, CodingKey {
                case total = "total_count"
            }
        }
    }
    
    struct Image: Codable {
        var source: String
        var height: Int
        var width: Int
    }
    
}
