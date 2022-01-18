//
//  Photo.swift
//  Flickry
//
//  Created by melaabd on 1/17/22.
//

import Foundation

protocol PhotoURL {}

struct Photos: Codable {
    var photos: PhotosClass
}

struct PhotosClass: Codable {
    var page, pages, perpage, total: Int
    var photo: [Photo]
}

struct Photo: Codable, PhotoURL {
    var id, owner, secret, server: String
    var farm: Int
    var title: String
    var ispublic, isfriend, isfamily: Int
}

extension PhotoURL where Self == Photo {
    
    func getImagePath() -> URL? {
        let path = "http://farm\(self.farm).static.flickr.com/\(self.server)/\(self.id)_\(self.secret).jpg"
        return URL(string: path)
    }
    
}
