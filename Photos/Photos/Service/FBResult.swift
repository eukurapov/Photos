//
//  FBResult.swift
//  Photos
//
//  Created by Eugene Kurapov on 28.10.2020.
//

import Foundation

struct FBResult<Element>: Codable where Element: Codable {
    
    var elements: [Element]
    private var paging: Paging
    
    var next: String? {
        get { paging.next }
        set { paging.next = newValue }
    }
    
    struct Paging: Codable {
        var next: String?
    }
    
    enum CodingKeys: String, CodingKey {
        case elements = "data"
        case paging
    }
    
}
