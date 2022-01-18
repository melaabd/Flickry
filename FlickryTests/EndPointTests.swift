//
//  EndPointTests.swift
//  FlickryTests
//
//  Created by melaabd on 19/01/2022.
//

import XCTest
@testable import Flickry

class EndPointTests: XCTestCase {
    
    func testEndPoint() {
        
        let endpoint = EndPoint.photos(keyword: "cat", page: 1)
        XCTAssertEqual(endpoint.url, URL(string: "https://api.flickr.com/services/rest/?method=flickr.photos.search&format=json&nojsoncallback=1&safe_search=1&text=cat&api_key=3e7cc266ae2b0e0d78e279ce8e361736"))
        
    }
}
