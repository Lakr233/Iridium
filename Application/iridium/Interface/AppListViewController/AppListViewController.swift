//
//  ViewController.swift
//  iridium
//
//  Created by Lakr Aream on 2022/1/7.
//

import AppListProto
import SPIndicator
import SwifterSwift
import SwiftThrottle
import UIKit

class AppListViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!

    let reuseId = UUID().uuidString

    var origDataSource = [AppListElement]() {
        didSet {
            updateSearchResult(with: searchText)
        }
    }

    var displayDataSource = [AppListElement]() {
        didSet {
            tableView.reloadData()
        }
    }

    var searchText: String = ""
    let searchThrottle = Throttle(minimumDelay: 0.5, queue: .global())
    let updateThrottle = Throttle(minimumDelay: 0.5, queue: .main)

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Apps"

        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = .clear
        tableView.register(AppCell.self, forCellReuseIdentifier: reuseId)

        searchBar.placeholder = "Search with..."
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self

        reloadAppListFromSource()

        hideKeyboardWhenTappedAround()

        let refreshButton = UIBarButtonItem(
            image: UIImage(systemName: "arrow.counterclockwise.circle"),
            style: .plain,
            target: self,
            action: #selector(refresh)
        )
        navigationItem.rightBarButtonItem = refreshButton
    }

    @objc func refresh() {
        updateThrottle.throttle {
            self.reloadAppListFromSource()
        }
    }

    func reloadAppListFromSource() {
        debugPrint("begin \(#function)")
        defer {
            debugPrint("complete \(#function)")
            SPIndicator.present(
                title: "App List Updated",
                message: "",
                preset: .done,
                haptic: .success
            )
        }
//        #if DEBUG
//            origDataSource = AppListTransfer
//                .decode(jsonString: mockJsonStr)!
//                .applications
//                .sorted { $0.localizedName < $1.localizedName }
//                .filter { !$0.bundleIdentifier.hasPrefix("com.apple.") }
//        #else
        origDataSource = Agent
            .shared
            .generateAppList()
//        #endif
    }
}
