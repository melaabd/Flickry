//
//  EndPoint.swift
//  Flickry
//
//  Created by melaabd on 18/01/2022.
//

import Foundation

enum EndPoint {
    
    static let baseUrl = "https://api.flickr.com/services/rest/?method=flickr.photos.search"
    static let apiKey = "3e7cc266ae2b0e0d78e279ce8e361736"
    
    case photos(keyword:String, page:Int)
    
    /// return router's path `String`
    private var path : String {
        switch self {
        case .photos(let keyword, let page):
            return "format=json&nojsoncallback=1&safe_search=\(page)&text=\(keyword)"
        }
    }
    
    var url:URL {
        guard let url = URL(string: "\(EndPoint.baseUrl)&\(path)&api_key=\(EndPoint.apiKey)") else {fatalError("Invalid Base URL.")}
        return url
    }
}
