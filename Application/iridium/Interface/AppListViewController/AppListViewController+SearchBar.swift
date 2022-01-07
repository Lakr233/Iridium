//
//  AppListViewController+SearchBar.swift
//  iridium
//
//  Created by Lakr Aream on 2022/1/7.
//

import AppListProto
import SwiftThrottle
import UIKit

extension AppListViewController: UISearchBarDelegate {
    func searchBar(_: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        searchThrottle.throttle {
            DispatchQueue.main.async {
                self.updateSearchResult(with: searchText)
            }
        }
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        let get = searchBar.searchTextField.text ?? ""
        searchText = get
        searchThrottle.throttle {
            DispatchQueue.main.async {
                self.updateSearchResult(with: get)
            }
        }
    }

    func updateSearchResult(with check: String) {
        assert(Thread.isMainThread, "required for main thread")
        guard searchText == check else {
            return
        }
        debugPrint("Searching for \(check)")
        if check.count < 1 {
            displayDataSource = origDataSource
            return
        }
        displayDataSource = filteringDataSource(with: origDataSource, and: check)
    }

    private func filteringDataSource(
        with allApps: [AppListElement],
        and searchKey: String
    ) -> [AppListElement] {
        allApps.filter { isValidResult(for: $0, when: searchKey) }
    }

    private func buildSearchKey(with app: AppListElement) -> [String] {
        [
            app.bundleIdentifier,
            app.localizedName,
            app.shortVersion,
            app.version,
        ]
    }

    private func isValidResult(for app: AppListElement, when search: String) -> Bool {
        let searchKeys = buildSearchKey(with: app)
        for key in searchKeys {
            if key.lowercased().contains(search.lowercased()) {
                return true
            }
        }
        return false
    }
}
