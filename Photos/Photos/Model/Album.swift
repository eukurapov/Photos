//
//  Album.swift
//  Photos
//
//  Created by Eugene Kurapov on 12.10.2020.
//

import Foundation

struct Album {
    
    var name: String
    var createdAt: Date
    var coverImagePath: String
    var photos = [Photo]()
    
    var coverImageUrl: URL? {
        URL(string: coverImagePath)
    }
    
}
