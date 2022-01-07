//
//  AppListViewController+TableView.swift
//  iridium
//
//  Created by Lakr Aream on 2022/1/7.
//

import AppListProto
import DropDown
import SnapKit
import SwifterSwift
import UIKit

extension AppListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        displayDataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseId, for: indexPath) as! AppCell
        cell.clearStatus()
        if let data = displayDataSource[safe: indexPath.row] {
            cell.setApp(data)
        }
        return cell
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        85
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath),
              let data = displayDataSource[safe: indexPath.row]
        else {
            return
        }
        let dropDownAnchor = UIView()
        cell.contentView.addSubview(dropDownAnchor)
        dropDownAnchor.snp.makeConstraints { x in
            x.right.equalToSuperview().offset(-8)
            x.bottom.equalToSuperview().offset(8)
            x.width.equalTo(233)
        }
        let dropDown = DropDown(anchorView: dropDownAnchor,
                                selectionAction: { index, _ in
                                    if index == 0 {
                                        self.dispatchDecrypt(app: data)
                                    } else if index == 1 {
                                        data.bundleURL.openInFilza()
                                    } else {
                                        debugPrint("invalid/canceled action")
                                    }
                                },
                                dataSource:
                                [
                                    "Decrypt Now",
                                    "Filza Open Bundle",
                                    "Cancel",
                                ]
                                .invisibleSpacePadding())
        DispatchQueue.main.async {
            dropDown.show(onTopOf: self.view.window)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            dropDownAnchor.removeFromSuperview()
        }
    }

    func dispatchDecrypt(app: AppListElement) {
        let controller = DecrypterViewController()
        controller.app = app
        controller.modalTransitionStyle = .coverVertical
        controller.modalPresentationStyle = .formSheet
        controller.isModalInPresentation = true
        controller.preferredContentSize = CGSize(width: 700, height: 555)
        present(controller, animated: true, completion: nil)
    }
}
