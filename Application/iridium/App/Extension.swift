//
//  Extension.swift
//  iridium
//
//  Created by Lakr Aream on 2022/1/7.
//

import UIKit

extension URL {
    func openInFilza() {
        let urlString = "filza://" + path
        if let url = URL(string: urlString),
           UIApplication.shared.canOpenURL(url)
        {
            UIApplication.shared.open(url, options: [:])
        } else {
            let alert = UIAlertController(title: "Error",
                                          message: "Filza is required for this operation",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Understand",
                                          style: .default, handler: nil))
            UIApplication
                .shared
                .windows
                .first?
                .topMostViewController?
                .present(alert, animated: true, completion: nil)
        }
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension [String] {
    func invisibleSpacePadding() -> Self {
        // padding it 🥺
        map { "⁠\u{200b}   \($0)⁠   \u{200b}" }
    }
}

extension UIWindow {
    var topMostViewController: UIViewController? {
        var result: UIViewController? = rootViewController
        while true {
            if let next = result?.presentedViewController {
                result = next
                continue
            }
            if let tabbar = result as? UITabBarController,
               let next = tabbar.selectedViewController
            {
                result = next
                continue
            }
            if let split = result as? UISplitViewController,
               let next = split.viewControllers.last
            {
                result = next
                continue
            }
            if let navigator = result as? UINavigationController,
               let next = navigator.viewControllers.last
            {
                result = next
                continue
            }
            break
        }
        return result
    }
}
