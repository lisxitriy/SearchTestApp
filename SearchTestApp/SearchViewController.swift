//
//  SearchViewController.swift
//  SearchTestApp
//
//  Created by Olga Trofimova on 16.04.2021.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    weak var splitViewDetail: DetailViewController?
    var landscapeVC: LandscapeViewController?
    private let search = Search()
    
    
    struct TableView {
      struct CellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let loadingCell = "LoadingCell"
      }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 94, left: 0, bottom: 0, right: 0)
//        
        var cellNib = UINib(nibName: TableView.CellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.searchResultCell)
    
        cellNib = UINib(nibName: TableView.CellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.nothingFoundCell)
        
        cellNib = UINib(nibName: TableView.CellIdentifiers.loadingCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.loadingCell)
        
//        показывать клавиатуру сразу при запуске приложения
        if UIDevice.current.userInterfaceIdiom != .pad {
            searchBar.becomeFirstResponder()
        }
        
        title = NSLocalizedString("Search", comment: "split view primary button")
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        switch newCollection.verticalSizeClass {
            case .compact:
                if newCollection.horizontalSizeClass == .compact{
                    showLandscape(with: coordinator)
                }
            case .regular, .unspecified: hideLandscape(with: coordinator)
            @unknown default:
                break
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UIDevice.current.userInterfaceIdiom == .phone {
            navigationController?.navigationBar.isHidden = true
        }
    }

    @IBAction func segmentedChanged(_ sender: UISegmentedControl) {
       performSearch()
    }
    
    //    MARK: - Navigaiton
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "ShowDetail" {
                if case .results(let list) = search.state {
//                    segue.destination.modalPresentationStyle = .overFullScreen
                    let detailVC = segue.destination as! DetailViewController
                    let indexPath = sender as! IndexPath
                    let searchResult = list[indexPath.row]
                    detailVC.searchResult = searchResult
                    detailVC.isPopUp = true
                }
            }
        }
    
    //MARK: - Helper Method

    func showNetworkError() {
        let alert = UIAlertController(title: NSLocalizedString("Wooops...", comment: "Error alert: title"), message: NSLocalizedString("There was an error accessing the Itunes Store. Please try again", comment: "Error alert: message") , preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func showLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
        guard landscapeVC == nil else { return }
        landscapeVC = storyboard!.instantiateViewController(withIdentifier: "LandscapeViewController") as? LandscapeViewController
        if let controller = landscapeVC {
            controller.search = search
            controller.view.frame = view.bounds
            controller.view.alpha = 0
            view.addSubview(controller.view)
            addChild(controller)
                
            coordinator.animate { _ in
                controller.view.alpha = 1
                self.searchBar.resignFirstResponder()
                if self.presentedViewController != nil {
                    self.dismiss(animated: true, completion: nil)
                }
                } completion: { _ in
                    controller.didMove(toParent: self)
                }

            }
        }
    
    func hideLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
        if let controller = landscapeVC {
            controller.willMove(toParent: nil)
            coordinator.animate { _ in
                controller.view.alpha = 0
                if self.presentedViewController != nil {
                  self.dismiss(animated: true, completion: nil)
                }
            } completion: { _ in
                controller.view.removeFromSuperview()
                controller.removeFromParent()
                self.landscapeVC = nil
            }

        }
    }
    
    private func hidePrimaryPane() {
        UIView.animate(withDuration: 0.25) {
            self.splitViewController?.preferredDisplayMode = .secondaryOnly
        } completion: { _ in
            self.splitViewController?.preferredDisplayMode = .automatic
        }

    }
 }

//MARK: - Search Bar Delegate

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch()
    }
    
    func performSearch() {
      if let category = Search.Category(rawValue: segmentedControl.selectedSegmentIndex) {
         search.performSearch(for: searchBar.text!, category: category) { success in
            if !success {
                self.showNetworkError()
             }
            self.tableView.reloadData()
            self.landscapeVC?.searchResultsReceived()
        }
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
    }
    
     func position(for bar: UIBarPositioning) -> UIBarPosition {
      return .topAttached
    }
}
//MARK: - Table View Delegate
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch search.state {
        case .notSearchedYet:
            return 0
        case .loading:
            return 1
        case .noResults:
            return 1
        case .results(let list):
            return list.count
      }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch search.state {
        case .notSearchedYet:
            fatalError("Should never get here")
        case .loading:
            let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.loadingCell, for: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        case .noResults:
            return tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.nothingFoundCell, for: indexPath)
        case .results(let list):
            let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
            let searchResult = list[indexPath.row]
            cell.configure(for: searchResult)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        searchBar.resignFirstResponder()
        
        if view.window!.rootViewController?.traitCollection.horizontalSizeClass == .compact {
            tableView.deselectRow(at: indexPath, animated: true)
            performSegue(withIdentifier: "ShowDetail", sender: indexPath)
        } else {
            if case .results(let list) = search.state {
                splitViewDetail?.searchResult = list[indexPath.row]
            }
            if splitViewController?.displayMode != .oneBesideSecondary {
                hidePrimaryPane()
            }
        }
    
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {

        switch search.state {
        case .notSearchedYet, .loading, .noResults:
            return nil
        case .results:
            return indexPath
        }

    }

}
 

