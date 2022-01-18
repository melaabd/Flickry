//
//  SearchVM.swift
//  Flickry
//
//  Created by melaabd on 1/17/22.
//

import Foundation

typealias CompletionVoid = (()->Void)

class SearchVM {
    
    weak var bindingDelegate: BindingVVMDelegate?
    var photoCellVMs:[PhotoCellVM]?
    var showLoading: CompletionVoid?
    var hideLoading: CompletionVoid?
    var imgProvider = ImgProvider()
    private var router:Router?
    
    var pageCount = 1 {
        didSet {
            if pageCount > 1 {
                search()
            }
        }
    }
    
    private var lastSearchTxt:String = ""
    
    func search(text:String? = nil) {
        if let searchTxt = text {
            lastSearchTxt = searchTxt
        }
        showLoading?()
        if router == nil {
            router = Router()
        }
        router?.getPhotos(keyword: lastSearchTxt, page: pageCount) { [weak self] photos, errorMsg in
            self?.hideLoading?()
            guard errorMsg == nil else {
                guard self?.router?.requestCancelStatus == false else { return }
                self?.bindingDelegate?.notifyFailure(msg: errorMsg!)
                return
            }
            guard let photos = photos?.photos.photo else { return }
            self?.prepareDataSource(photos: photos)
        }
    }
    
    private func prepareDataSource(photos: [Photo]) {
        let photoVMs = photos.map{PhotoCellVM(photo: $0)}
        if pageCount > 1 {
            photoCellVMs?.append(contentsOf: photoVMs)
        } else {
            photoCellVMs = photoVMs
        }
        bindingDelegate?.reloadData()
    }
    
    //MARK: - Clearing here old data search results with current running tasks
    func resetValuesForNewSearch() {
        pageCount = 1
        router?.cancelTask()
        photoCellVMs?.removeAll()
        bindingDelegate?.reloadData()
    }
}
