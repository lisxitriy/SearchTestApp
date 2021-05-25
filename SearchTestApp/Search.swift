//
//  Search.swift
//  SearchTestApp
//
//  Created by Olga Trofimova on 12.05.2021.
//

import Foundation

typealias SearchComplete = (Bool) -> Void

class Search {
    
    enum Category: Int {
        case all = 0
        case music = 1
        case software = 2
        case ebooks = 3
        
        var type: String {
            switch self {
            case .all: return ""
            case .music: return "musicTrack"
            case .software: return "software"
            case .ebooks: return "ebook"
            }
        }
    }
    
    enum State {
        case notSearchedYet
        case loading
        case noResults
        case results([SearchResult])
    }
    
    private(set) var state: State = .notSearchedYet
    private var dataTask: URLSessionDataTask?
    
    
    // MARK: - Helper methods
    func performSearch(for text: String, category: Category, completion: @escaping SearchComplete) {
        print("Searching...")
        if !text.isEmpty {
            dataTask?.cancel()
            state = .loading
        
            let url = itunesURL(searchText: text, category: category)
            
            let session = URLSession.shared
            dataTask = session.dataTask(with: url) { data, response, error in
            
                var newState = State.notSearchedYet
                var success = false
                if let error = error as NSError?, error.code == -999 {
        //                    print("Failure! \(error.localizedDescription)")
                        return
                    }
                    
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data {
                    var searchResults = self.parse(data: data)
                    if searchResults.isEmpty {
                        newState = .noResults
                    } else {
                        searchResults.sort(by: <)
                        newState = .results(searchResults)
                    }
                     success = true
                }
                
                DispatchQueue.main.async {
                    self.state = newState
                    completion(success)
                    }
                }
            dataTask?.resume()
            }
        }
    
    // MARK: - Private methods
private func itunesURL(searchText: String, category: Search.Category) -> URL {
    
    let local = Locale.autoupdatingCurrent
    let language = local.identifier
    let countryCode = local.regionCode ?? "en_US"
        
    let kind = category.type

    let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
    let urlString = "https://itunes.apple.com/search?" + "term=\(encodedText)&limit=200&entity=\(kind)" + "&lang=\(language)&country=\(countryCode)"
    let url = URL(string: urlString)
    print("URL: \(url!)")
    return url!
    }
    
    private func parse(data: Data) -> [SearchResult] {
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(ResultArray.self, from: data)
            return result.results
        } catch {
            print("JSON Error: \(error)")
        return []
        }
    }

}


//func performSearch() {
//    
//    if !searchBar.text!.isEmpty {
//        //        скрыть клавиатуру по тапу на поиск
//        searchBar.resignFirstResponder()
//    dataTask?.cancel()
//        
//      isLoading = true
//      tableView.reloadData()
//
//      hasSearched = true
//      searchResults = []
//
//        let url = itunesURL(searchText: searchBar.text!, category: segmentedControl.selectedSegmentIndex)
//        let session = URLSession.shared
//        dataTask = session.dataTask(with: url) { data, response, error in
//            if let error = error as NSError?, error.code == -999 {
////                    print("Failure! \(error.localizedDescription)")
//                return
//            } else if let httpResponse = response as? HTTPURLResponse,
//                      httpResponse.statusCode == 200 {
//                if let data = data {
//                    self.searchResults = self.parse(data: data)
//                    self.searchResults.sort(by: <)
//                    DispatchQueue.main.async {
//                        self.isLoading = false
//                        self.tableView.reloadData()
//                    }
//                    return
//                }
//            } else {
//                print("Failure! \(response!)")
//            }
//            
//            DispatchQueue.main.async {
//                self.hasSearched = false
//                self.isLoading = false
//                self.tableView.reloadData()
//                self.showNetworkError()
//            }
//        
//        }
//        dataTask?.resume()
//}
