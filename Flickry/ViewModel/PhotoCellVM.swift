//
//  PhotoCellVM.swift
//  Flickry
//
//  Created by melaabd on 18/01/2022.
//

import Foundation


class PhotoCellVM {
    
    var photoUrl:URL?
    
    init(photo: Photo) {
        photoUrl = photo.getImagePath()
    }
}
