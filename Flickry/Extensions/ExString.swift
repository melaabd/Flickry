//
//  ExString.swift
//  Flickry
//
//  Created by melaabd on 1/17/22.
//

import Foundation

extension String {
    func removeSpace() -> String {
        if !isEmpty {
            return self.components(separatedBy: .whitespaces).joined()
        } else {
            return ""
        }
    }
}
