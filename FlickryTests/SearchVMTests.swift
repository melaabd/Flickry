//
//  FlickryTests.swift
//  FlickryTests
//
//  Created by melaabd on 1/17/22.
//

import XCTest
@testable import Flickry


class SearchVMTests: XCTestCase {

    var searchVM: SearchVM!
    
    override func setUp() {
        super.setUp()
        
        searchVM = SearchVM()
    }
    
    override func tearDown() {
        
        searchVM = nil
        super.tearDown()
    }

    func testInitialization() {
        XCTAssertNotNil(searchVM, "The view model should not be nil.")
        XCTAssertNotNil(searchVM.imgProvider)
        XCTAssertEqual(searchVM.pageCount, 1)
    }
    
    func testFunctionality() {
        
        // Convert Photos.json to Data
        let testBundle = Bundle(for: type(of: self))
        let path = testBundle.path(forResource: "Photos", ofType: "json")
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path!), options: .alwaysMapped) else {
            fatalError("Data is nil")
        }
        
        // Provie any Codable struct
        let photosResponse = try! JSONDecoder().decode(Photos.self, from: data)
        
        XCTAssertNotNil(photosResponse.photos)
        XCTAssertNotNil(photosResponse.photos.photo)
        XCTAssertEqual(photosResponse.photos.photo.first?.id, "51829315844")
        
        searchVM.prepareDataSource(photos: photosResponse.photos.photo)
        
        XCTAssertNotNil(searchVM.photoCellVMs)
        let photoUrl = searchVM.photoCellVMs?.first?.photoUrl
        XCTAssertNotNil(photoUrl)
        XCTAssertEqual(photoUrl, URL(string: "http://farm66.static.flickr.com/65535/51829315844_1f1e6d72ce.jpg"))
        
    }
    
    func testSearchHistoryFunctionality() {
        
        searchVM.search(text: "cat")
        searchVM.search(text: "dog")
        searchVM.search(text: "flower")
        searchVM.search(text: "dodg")
        searchVM.search(text: "cater")
        
        XCTAssertEqual(searchVM.searchHistory,["cat", "dog", "flower", "dodg", "cater"])
        
        searchVM.filterHistory(txt: "ca")
        XCTAssertEqual(searchVM.filteredSearchHistory.count, 2)
        
        searchVM.removeSearchHistoryItem(item: "cater")
        
        searchVM.filterHistory(txt: "ca")
        XCTAssertEqual(searchVM.filteredSearchHistory.count, 1)
        
    }
    
    
}
