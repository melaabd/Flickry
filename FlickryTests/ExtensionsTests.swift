//
//  ExtensionsTests.swift
//  FlickryTests
//
//  Created by melaabd on 19/01/2022.
//

import XCTest
@testable import Flickry

class ExtensionsTests: XCTestCase {

    func testStringExtension() {
        XCTAssertEqual("Hello Flickry".removeSpace(), "HelloFlickry")
    }

}
