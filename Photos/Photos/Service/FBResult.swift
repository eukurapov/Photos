//
//  FBResult.swift
//  Photos
//
//  Created by Eugene Kurapov on 28.10.2020.
//

import Foundation

struct FBResult<Element>: Codable where Element: Codable {
    var data: [Element]
    var paging: Paging
    
    struct Paging: Codable {
        var next: String?
    }
}
