//
//  Photo.swift
//  Photos
//
//  Created by Eugene Kurapov on 12.10.2020.
//

import Foundation

struct Photo: Equatable {
    
    var name: String
    var createdAt: Date
    var imagePath: String
    
    var imageURL: URL? {
        URL(string: imagePath)
    }
    
}
