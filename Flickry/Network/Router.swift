//
//  Router.swift
//  Flickry
//
//  Created by melaabd on 1/17/22.
//

import Foundation

typealias PhotosAPICompletion = ((_ photos: Photos?, _ errorMsg:String?) -> Void)?

protocol RequestFlickrImages {}

class Router: RequestFlickrImages {
    
    var requestCancelStatus = false
    private var task: URLSessionTask?
    
    //MARK: - Cancel all previous tasks
    func cancelTask(){
        requestCancelStatus = true
        task?.cancel()
    }
    
    /**
     Adding here timeout for cancel current task if any case request not getting success or taking too much time because of internet. Default time out is 15 seconds.
     */
    private func requestTimeOut() {
        GCD.onMain(after: 20) { [weak self] in
            self?.task?.resume()
        }
    }
}

extension Router {
    
    /// get photos task
    /// - Parameters:
    ///   - keyword: `String` search keyword
    ///   - page: `Int` next page
    ///   - completionHandler: `PhotosAPICompletion`
    func getPhotos(keyword: String, page: Int, completionHandler: PhotosAPICompletion) {
        let session = URLSession.shared
        let endPoint = EndPoint.photos(keyword: keyword, page: page)
        
        //Set timeout for request
        requestTimeOut()
        
        task = session.photosTask(with: endPoint.url, completionHandler: { photos, error in
            GCD.onMain {
                completionHandler?(photos, error)
            }
        })
        task?.resume()
    }
}
