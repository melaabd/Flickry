//
//  ExUICollectionView.swift
//  Flickry
//
//  Created by melaabd on 18/01/2022.
//

import UIKit


extension UICollectionView {
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
    
    func isLast(for indexPath: IndexPath, offset:Int = 2) -> Bool {
        let indexOfLastSection = numberOfSections > 0 ? numberOfSections - 1 : 0
        let indexOfLastRowInLastSection = numberOfItems(inSection: indexOfLastSection) - offset
        return indexPath.section == indexOfLastSection && indexPath.item == indexOfLastRowInLastSection
    }
}

