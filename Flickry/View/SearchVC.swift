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
    
    private func configureUI() {
        
        title = "Flickrs"
        navigationController?.navigationBar.prefersLargeTitles = true
        createSearchBar()
    }
    
    private func viewModelCompletions() {
        searchVM?.showLoading = {
            GCD.onMain { [weak self] in
                self?.loadingLbl.isHidden = false
            }
        }
        searchVM?.hideLoading = {
            GCD.onMain { [weak self] in
                self?.loadingLbl.isHidden = true
            }
        }
    }
    
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
}

//MARK: - SearchBar Delegate
extension SearchVC: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
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
}

//MARK: - Collection View DataSource
extension SearchVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let itemsCount = searchVM?.photoCellVMs?.count ?? 0
        (itemsCount > 0) ? collectionView.setEmptyView() : collectionView.setEmptyView("No Items")
        return itemsCount
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: PhotoCVCell.self), for: indexPath) as? PhotoCVCell ?? PhotoCVCell()
        cell.imageView.image = nil
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
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
    
}

//MARK:- UICollectionViewDelegateFlowLayout
extension SearchVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width)/2, height: (collectionView.bounds.width)/2)
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
