//
//  GCDTests.swift
//  FlickryTests
//
//  Created by melaabd on 19/01/2022.
//

import XCTest
@testable import Flickry

class GCDTests: XCTestCase {
    
    func testThreads() {
        
        GCD.onMain {
            XCTAssertTrue(Thread.current.isMainThread)
        }
        
        let downloadQueue = DispatchQueue(label: "Images cache", qos: DispatchQoS.background)
        
        downloadQueue.async(execute: { () -> Void in
            XCTAssertFalse(Thread.current.isMainThread)
        })
        
    }
}
