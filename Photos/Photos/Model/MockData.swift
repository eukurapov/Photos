//
//  MockData.swift
//  Photos
//
//  Created by Eugene Kurapov on 12.10.2020.
//

import Foundation

struct MockData {
    
    static let album1: Album = {
        var album = Album(name: "First Album", createdAt: Date(), coverImagePath: "https://www.polar.com/sites/default/files/sc/running-index-intro-bg-desktop.jpg")
        album.photos = [
            Photo(name: "Some", createdAt: Date(), imagePath: "https://www.verywellfit.com/thmb/-DnhvXONy3CEItihSRir4bo6syw=/1500x844/smart/filters:no_upscale()/Snapwire-Running-27-66babd0b2be44d9595f99d03fd5827fd.jpg"),
            Photo(name: "More", createdAt: Date(), imagePath: "https://www.polar.com/sites/default/files/sc/running-index-intro-bg-desktop.jpg"),
            Photo(name: "Superphotonumberthree", createdAt: Date(), imagePath: "https://i.insider.com/5f1f41f11918244ec622b465?width=1100&format=jpeg&auto=webp"),
            Photo(name: "Another One", createdAt: Date(), imagePath: "https://www.runtastic.com/blog/wp-content/uploads/2018/05/optimizing-running-training-relaxation-stress-solar-boost-shoes.jpg")
        ]
        return album
    }()
    static let album2 = Album(name: "Second", createdAt: Date(), coverImagePath: "https://www.verywellfit.com/thmb/-DnhvXONy3CEItihSRir4bo6syw=/1500x844/smart/filters:no_upscale()/Snapwire-Running-27-66babd0b2be44d9595f99d03fd5827fd.jpg")
    static let album3 = Album(name: "Another One", createdAt: Date(), coverImagePath: "https://www.runtastic.com/blog/wp-content/uploads/2018/05/optimizing-running-training-relaxation-stress-solar-boost-shoes.jpg")
    static let album4 = Album(name: "And One More", createdAt: Date(), coverImagePath: "https://i.insider.com/5f1f41f11918244ec622b465?width=1100&format=jpeg&auto=webp")
    static let album5 = Album(name: "First Album", createdAt: Date(), coverImagePath: "https://www.polar.com/sites/default/files/sc/running-index-intro-bg-desktop.jpg")
    static let album6 = Album(name: "Second", createdAt: Date(), coverImagePath: "https://www.verywellfit.com/thmb/-DnhvXONy3CEItihSRir4bo6syw=/1500x844/smart/filters:no_upscale()/Snapwire-Running-27-66babd0b2be44d9595f99d03fd5827fd.jpg")
    static let album7 = Album(name: "Another One", createdAt: Date(), coverImagePath: "https://www.runtastic.com/blog/wp-content/uploads/2018/05/optimizing-running-training-relaxation-stress-solar-boost-shoes.jpg")
    static let album8 = Album(name: "And One More", createdAt: Date(), coverImagePath: "https://i.insider.com/5f1f41f11918244ec622b465?width=1100&format=jpeg&auto=webp")
    

    static let albums: [Album] = [album1, album2, album3, album4, album5, album6, album7, album8]
    
}
