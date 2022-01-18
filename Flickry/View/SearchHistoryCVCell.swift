//
//  SearchHistoryCVCell.swift
//  Flickry
//
//  Created by melaabd on 18/01/2022.
//

import UIKit

class SearchHistoryCVCell: UICollectionViewCell {
    
    
    var removeItemCompletion:CompletionVoid?
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var removeBtn: UIButton!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        removeBtn.layer.cornerRadius = (removeBtn.frame.height / 2)
    }
    
    
    @IBAction func removeBtnAction(_ sender: UIButton) {
        removeItemCompletion?()
    }
    
}
