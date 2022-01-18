//
//  GCD.swift
//  Flickry
//
//  Created by melaabd on 1/18/22.
//

import UIKit

class GCD {
    
    ///  execute block of code in main thread
    /// - Parameters:
    ///   - after: `Int` delay in seconds
    ///   - execute:  clouser
    static func onMain(after: Int = 0, execute:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(after), execute: execute)
    }
}
