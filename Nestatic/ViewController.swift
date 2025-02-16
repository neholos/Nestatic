//
//  ViewController.swift
//  Nestatic
//
//  Created by Sasha Jaroshevskii on 15.02.2025.
//

import UIKit
import GiphyUISDK
import SnapKit

final class ViewController: UIViewController {
    private let bundle = Bundle.main
    
    private lazy var giphyAPIKey = bundle.object(forInfoDictionaryKey: "GIPHYAPIKey") as! String
    
    private var searchTask: Task<Void, Never>?
    
    private lazy var searchController: UISearchController = {
        let controller = UISearchController()
        controller.searchResultsUpdater = self
        return controller
    }()
    
    private lazy var gridController: GiphyGridController = {
        let controller = GiphyGridController()
        controller.setAPIKey(giphyAPIKey)
        controller.cellPadding = 2.0
        controller.direction = .vertical
        controller.numberOfTracks = 3
        controller.fixedSizeCells = true
        return controller
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationItem.searchController?.searchBar.becomeFirstResponder()
    }
    
    private func setupUI() {
        navigationItem.searchController = searchController
        view.backgroundColor = .systemBackground
        
        addChild(gridController)
        view.addSubview(gridController.view)
        
        gridController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        gridController.didMove(toParent: self)
    }
}

extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text, !query.isEmpty else { return }
        
        searchTask?.cancel()
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            gridController.content = GPHContent.search(withQuery: query, mediaType: .gif, language: .english)
            gridController.update()
        }
    }
}
