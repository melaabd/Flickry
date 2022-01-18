//
//  ExString.swift
//  Flickry
//
//  Created by melaabd on 1/17/22.
//

import Foundation

extension String {
    
    /// remove spaces from string
    /// - Returns: `String` after remove spaces
    func removeSpace() -> String {
        if !isEmpty {
            return self.components(separatedBy: .whitespaces).joined()
        } else {
            return ""
        }
    }
}
