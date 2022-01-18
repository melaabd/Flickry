//
//  ViewController.swift
//  Flickry
//
//  Created by melaabd on 1/17/22.
//

import UIKit

/// Binding delegate to connect between VC and VM
protocol BindingVVMDelegate: AnyObject {
    func reloadData()
    func notifyFailure(msg: String)
}

class SearchVC: UIViewController {
    
    @IBOutlet weak var photosCollectionView: UICollectionView!
    @IBOutlet weak var loadingLbl: UILabel!
    private var searchControler: UISearchController!
    
    var searchVM: SearchVM?
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchVM = SearchVM()
        searchVM?.bindingDelegate = self
        configureUI()
        viewModelCompletions()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// setup UI components
    private func configureUI() {
        
        title = "Flickrs"
        navigationController?.navigationBar.prefersLargeTitles = true
        createSearchBar()
    }
    
    /// conform with completions that called in viewmodel
    private func viewModelCompletions() {
        
        // show loading sign
        searchVM?.showLoading = {
            GCD.onMain { [weak self] in
                self?.loadingLbl.isHidden = false
            }
        }
        
        // hide loading sign
        searchVM?.hideLoading = {
            GCD.onMain { [weak self] in
                self?.loadingLbl.isHidden = true
            }
        }
    }
    
    /// intialize search controller with setting properties
    private func createSearchBar() {
        searchControler = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchControler
        searchControler.delegate = self
        searchControler.searchBar.delegate = self
        searchControler.searchBar.placeholder = "Search favorates images.."
        GCD.onMain { [weak self] in
            self?.searchControler.isActive = true
        }
    }
}


//MARK: - SearchController Delegate
extension SearchVC: UISearchControllerDelegate {
    func didPresentSearchController(_ searchController: UISearchController) {
        GCD.onMain { [weak self] in
            self?.searchControler.searchBar.becomeFirstResponder()
        }
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        searchVM?.isSearching = false
        reloadData()
    }
}

//MARK: - SearchBar Delegate
extension SearchVC: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchVM?.isSearching = false
        searchBar.resignFirstResponder()
        
        //Reset old data first befor new search Results
        searchVM?.resetValuesForNewSearch()
        
        guard let text = searchBar.text?.removeSpace(), text.count != 0  else {
            loadingLbl.isHidden = false
            
            //Requesting here new keyword
            loadingLbl.text = "Please type keyword to search result."
            return
        }
        
        ///Start search
        searchVM?.search(text: searchBar.text)
        loadingLbl.text = "Searching Images..."
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let text = searchBar.text?.removeSpace(), text.count != 0  else {return}
        searchVM?.isSearching = true
        searchVM?.filterHistory(txt: searchBar.text!)
    }
}

//MARK: - Collection View DataSource
extension SearchVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var itemsCount = 0
        itemsCount = (searchVM?.isSearching ?? false) ? searchVM?.filteredSearchHistory.count ?? 0 : searchVM?.photoCellVMs?.count ?? 0
        (itemsCount > 0) ? collectionView.setEmptyView() : collectionView.setEmptyView("No Items")
        return itemsCount
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if searchVM?.isSearching ?? false {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: SearchHistoryCVCell.self), for: indexPath) as? SearchHistoryCVCell ?? SearchHistoryCVCell()
            guard let itemTxt = searchVM?.filteredSearchHistory[indexPath.item] else { return cell }
            cell.titleLbl.text = itemTxt
            cell.removeItemCompletion = { [weak self] in
                self?.searchVM?.removeSearchHistoryItem(item: itemTxt)
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: PhotoCVCell.self), for: indexPath) as? PhotoCVCell ?? PhotoCVCell()
            cell.imageView.image = nil
            return cell
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard !(searchVM?.isSearching ?? false) else { return }
        if let cell = cell as? PhotoCVCell {
            guard let mediaUrl = searchVM?.photoCellVMs?[indexPath.row].photoUrl else { return }
            if let image = searchVM?.imgProvider.cache.object(forKey: mediaUrl as NSURL) {
                cell.imageView.image = image
            } else {
                searchVM?.imgProvider.requestImage(from :mediaUrl, completion: { (image) -> Void in
                    let indexPath_ = collectionView.indexPath(for: cell)
                    if indexPath == indexPath_ {
                        cell.imageView.image = image
                    }
                })
            }
        }
        /// check if it's last index should load more
        if collectionView.isLast(for: indexPath) {
            searchVM?.pageCount += 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard (searchVM?.isSearching ?? false), let itemTxt = searchVM?.filteredSearchHistory[indexPath.item] else { return }
        searchControler.searchBar.text = itemTxt
        searchBarSearchButtonClicked(searchControler.searchBar)
    }
    
}

//MARK:- UICollectionViewDelegateFlowLayout
extension SearchVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (searchVM?.isSearching ?? false) {
            return CGSize(width: collectionView.bounds.width , height: 50)
        } else {
            return CGSize(width: (collectionView.bounds.width)/2, height: (collectionView.bounds.width)/2)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

// MARK: - Conform with BaseVC Binding Protocol
extension SearchVC: BindingVVMDelegate, AlertDelegate {
    /// reload data delegate
    func reloadData() {
        GCD.onMain { [weak self] in
            self?.photosCollectionView.reloadData()
        }
    }
    
    /// show alert for user in case something went wrong
    /// - Parameter msg: alert message
    func notifyFailure(msg: String) {
        GCD.onMain { [weak self] in
            self?.showAlertWithError(msg, completionHandler: {[weak self] retry in
                if retry {
                    self?.searchVM?.search()
                }
            })
        }
    }
}
