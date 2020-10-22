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
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case createdAt = "created_time"
        case place
    }
    
    static func == (lhs: Photo, rhs: Photo) -> Bool {
        return lhs.id == rhs.id
    }
    
    struct Place: Codable {
        var name: String
        var location: Location
        
        struct Location: Codable {
            var country: String
            var city: String
            var latitude: Double
            var longitude: Double
        }
    }
    
}
