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
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case createdAt = "created_time"
    }
    
    static func == (lhs: Photo, rhs: Photo) -> Bool {
        return lhs.id == rhs.id
    }
    
}
