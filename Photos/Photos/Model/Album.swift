//
//  Album.swift
//  Photos
//
//  Created by Eugene Kurapov on 12.10.2020.
//

import Foundation

struct Album: Codable {
    
    var id: String
    var name: String
    var createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case createdAt = "created_time"
    }
    
}
