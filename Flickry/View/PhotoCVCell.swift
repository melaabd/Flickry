//
//  PhotoCVCell.swift
//  Flickry
//
//  Created by melaabd on 1/17/22.
//

import UIKit

class PhotoCVCell: UICollectionViewCell, RequestImages {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
        
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.layer.cornerRadius = 4
        imageView.backgroundColor = UIColor(white: 0.95, alpha: 1)
    }
}
