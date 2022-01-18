//
//  ExUICollectionView.swift
//  Flickry
//
//  Created by melaabd on 18/01/2022.
//

import UIKit


extension UICollectionView {
    
    /// show label that tell user message in the middle of collectionview
    /// - Parameter title: `String`
    func setEmptyView(_ title: String? = nil) {
        guard let txt = title else {
            backgroundView = nil
            return
        }
        let emptyView = UIView(frame: CGRect(x: center.x, y: center.y, width: bounds.size.width, height: bounds.size.height))
        emptyView.backgroundColor = .clear
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UIColor.lightGray
        titleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        emptyView.addSubview(titleLabel)
        titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor).isActive = true
        titleLabel.text = txt
        backgroundView = emptyView
    }
    
    /// check if it's last cell, used to call pagination or any action
    /// - Parameters:
    ///   - indexPath: `IndexPath` current index
    ///   - offset: `Int` this is custome offest to handle when you should recive it's last
    /// - Returns: `Bool` is it last
    func isLast(for indexPath: IndexPath, offset:Int = 2) -> Bool {
        let indexOfLastSection = numberOfSections > 0 ? numberOfSections - 1 : 0
        let indexOfLastRowInLastSection = numberOfItems(inSection: indexOfLastSection) - offset
        return indexPath.section == indexOfLastSection && indexPath.item == indexOfLastRowInLastSection
    }
}

