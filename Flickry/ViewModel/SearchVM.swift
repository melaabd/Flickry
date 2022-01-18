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
    var isSearching:Bool = false
    private var router:Router?
    
    var pageCount = 1 {
        didSet {
            if pageCount > 1 {
                search()
            }
        }
    }
    
    // search history properties
    var filteredSearchHistory:[String] = []
    var searchHistory:Set<String> = [] // store history in a `Set` to avoid dublication
    private var lastSearchTxt:String = ""
    
    /// search for photos by inout keyword
    /// - Parameter text: `String`
    func search(text:String? = nil) {
        if let searchTxt = text {
            searchHistory.insert(searchTxt)
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
    
    /// handle data in viewmodel
    /// - Parameter photos: `Photo` Model
    func prepareDataSource(photos: [Photo]) {
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

// MARK: - handle search history data
extension SearchVM {
    
    /// filter in search history
    /// - Parameter txt: `String`
    func filterHistory(txt: String) {
        filteredSearchHistory = searchHistory.filter{$0.contains(txt)}
        bindingDelegate?.reloadData()
    }
    
    /// remove item from old history
    /// - Parameter item: `String`
    func removeSearchHistoryItem(item: String) {
        searchHistory.remove(item)
        bindingDelegate?.reloadData()
    }
}
